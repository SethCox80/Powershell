<# 
Create Entra ID (Azure AD) users from CSV via Microsoft Graph

CSV headers (must match exactly):
First_Name, Last_Name, Display_Name, Username, Password, Grade

Notes:
- If Username lacks a domain, the script appends $DefaultDomain.
- If Password is empty, one will be auto-generated.
- Sets Department to "Grade <Grade>" so you can filter later.
- Forces password change at next sign-in (set to $false if you don’t want that).
- Does NOT unlock accounts or reset existing users.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,

    # Used only when a Username value does NOT already contain "@domain"
    [string]$DefaultDomain = ""
)

# 1) Ensure Microsoft Graph is available and connect
if (-not (Get-Module -ListAvailable Microsoft.Graph)) {
    Write-Host "Installing Microsoft.Graph..." -ForegroundColor Yellow
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph

$scopes = @('User.ReadWrite.All')
Connect-MgGraph -Scopes $scopes -NoWelcome | Out-Null

# Helper: Generate random password
function New-RandomPassword {
    param([int]$Length = 10)
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Max $chars.Length)] })
}

# 2) Load CSV
if (-not (Test-Path -Path $CsvPath)) {
    throw "CSV not found at: $CsvPath"
}
$rows = Import-Csv -Path $CsvPath

# 3) Process rows
foreach ($r in $rows) {
    $first      = ($r.'First_Name').Trim()
    $last       = ($r.'Last_Name').Trim()
    $display    = ($r.'Display_Name').Trim()
    $usernameIn = ($r.'Username').Trim()
    $password   = ($r.'Password')
    $grade      = ($r.'Grade').ToString().Trim()

    if ([string]::IsNullOrWhiteSpace($first) -or
        [string]::IsNullOrWhiteSpace($last)  -or
        [string]::IsNullOrWhiteSpace($display) -or
        [string]::IsNullOrWhiteSpace($usernameIn)) {
        Write-Warning "Skipping row with missing required fields: $($r | ConvertTo-Json -Compress)"
        continue
    }

    # Generate password if missing
    if ([string]::IsNullOrWhiteSpace($password)) {
        $password = New-RandomPassword
        Write-Host "Generated password for $usernameIn : $password" -ForegroundColor Cyan
    }

    # Build UPN and mailNickname
    $upn = if ($usernameIn -match '@') {
        $usernameIn
    } elseif ($DefaultDomain) {
        "$usernameIn@$DefaultDomain"
    } else {
        throw "Username '$usernameIn' has no domain and no -DefaultDomain was provided."
    }
    $mailNickname = ($upn -split '@')[0]

    # Skip if already exists
    $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    if ($existing) {
        Write-Host "User already exists, skipping: $upn" -ForegroundColor Yellow
        continue
    }

    $pwdProfile = @{
        Password                             = $password
        ForceChangePasswordNextSignIn        = $true
        ForceChangePasswordNextSignInWithMfa = $false
    }

    try {
        New-MgUser `
            -AccountEnabled:$true `
            -DisplayName $display `
            -GivenName $first `
            -Surname $last `
            -UserPrincipalName $upn `
            -MailNickname $mailNickname `
            -Department ("Grade " + $grade) `
            -PasswordProfile $pwdProfile | Out-Null

        Write-Host "Created: $upn" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to create $upn : $($_.Exception.Message)"
    }
}

Disconnect-MgGraph
Write-Host "Done." -ForegroundColor Green