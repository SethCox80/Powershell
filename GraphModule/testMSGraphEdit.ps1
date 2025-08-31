<#
.SYNOPSIS
  Tests Graph ability to CREATE and EDIT a user, then cleans up.
  - Creates a disabled temp user with a unique UPN
  - Updates a harmless field (jobTitle)
  - Deletes the temp user
  - Prints step-by-step results and optionally writes a CSV

.PARAMETER ExportCsvPath
  Optional path to save the test results as a CSV. Example: .\GraphUserWriteTest.csv

.PARAMETER Domain
  Optional UPN domain to use. If omitted, uses your tenant's default verified domain.

.NOTES
  Requires Scopes: User.ReadWrite.All
#>

param(
    [string]$ExportCsvPath = "",
    [string]$Domain = ""
)

# 1) Connect to Graph with the right permissions
if (-not (Get-Module -ListAvailable Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}
Connect-MgGraph -Scopes 'User.ReadWrite.All' -NoWelcome | Out-Null

function New-SecureRandomPassword {
    param([int]$Length = 16)
    # Meets default complexity (upper/lower/digit/symbol)
    $chars = @()
    $chars += (48..57)   # 0-9
    $chars += (65..90)   # A-Z
    $chars += (97..122)  # a-z
    $chars += (33, 35, 36, 37, 38, 64) # ! # $ % & @
    -join ((1..$Length) | ForEach-Object { [char]($chars | Get-Random) })
}

# 2) Pick a default verified domain if not provided
if (-not $Domain) {
    try {
        $defDomain = Get-MgDomain | Where-Object { $_.IsDefault -eq $true } | Select-Object -First 1
        if (-not $defDomain) {
            throw "No default verified domain found. Use -Domain to specify one (e.g. contoso.com)."
        }
        $Domain = $defDomain.Id
    }
    catch {
        Write-Error "Failed to get tenant domain: $($_.Exception.Message)"
        return
    }
}

# 3) Build a unique test user
$guid = ([guid]::NewGuid()).ToString().Substring(0, 8)
$mailNick = "graphwritetest$guid"
$upn = "$mailNick@$Domain"
$pwd = New-SecureRandomPassword 18
$display = "Graph Write Test ($guid)"

# 4) Run test steps
$results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param($Step, $Status, $Detail)
    $results.Add([pscustomobject]@{
            Timestamp = (Get-Date).ToString("s")
            Step      = $Step
            Status    = $Status
            Detail    = $Detail
            UPN       = $upn
        }) | Out-Null
}

# CREATE
try {
    Add-Result "CreateUser" "Starting" "Creating disabled temp user $upn"
    $params = @{
        AccountEnabled    = $false                       # keep disabled for safety
        DisplayName       = $display
        MailNickname      = $mailNick
        UserPrincipalName = $upn
        PasswordProfile   = @{
            ForceChangePasswordNextSignIn = $true
            Password                      = $pwd
        }
    }
    $newUser = New-MgUser @params -ErrorAction Stop
    Add-Result "CreateUser" "Success" "User created with id $($newUser.Id)"
}
catch {
    Add-Result "CreateUser" "Fail" "Create failed: $($_.Exception.Message)"
}

# UPDATE (only if created)
if ($newUser -and $newUser.Id) {
    try {
        Add-Result "UpdateUser" "Starting" "Updating jobTitle"
        Update-MgUser -UserId $newUser.Id -JobTitle "Graph Write Test $(Get-Date -Format s)" -ErrorAction Stop
        Add-Result "UpdateUser" "Success" "jobTitle updated"
    }
    catch {
        Add-Result "UpdateUser" "Fail" "Update failed: $($_.Exception.Message)"
    }
}
else {
    Add-Result "UpdateUser" "Skip" "Skipped because create failed"
}

# CLEANUP (delete temp user if it exists)
if ($newUser -and $newUser.Id) {
    try {
        Add-Result "DeleteUser" "Starting" "Deleting temp user"
        Remove-MgUser -UserId $newUser.Id -ErrorAction Stop -Confirm:$false
        Add-Result "DeleteUser" "Success" "Temp user deleted"
    }
    catch {
        Add-Result "DeleteUser" "Fail" "Delete failed: $($_.Exception.Message)"
    }
}
else {
    Add-Result "DeleteUser" "Skip" "Skipped because create failed"
}

# 5) Print summary
$results | Format-Table -AutoSize

# 6) Optional CSV export
if ($ExportCsvPath) {
    try {
        $results | Export-Csv -Path $ExportCsvPath -NoTypeInformation -Encoding UTF8
        Write-Host "Results exported to $ExportCsvPath"
    }
    catch {
        Write-Warning "Failed to export CSV: $($_.Exception.Message)"
    }
}
