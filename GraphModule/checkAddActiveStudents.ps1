<# 
    NewYearStudentsUnlockAdd-Graph.ps1
    Converted from MSOnline to Microsoft Graph PowerShell SDK

    CSV columns expected (same as original):
      - First Name
      - Last Name
      - Display Name
      - Username
      - Grade Level   (K,1,2,3,4,5,6,7,8)

    Key changes from MSOnline → Graph:
      - Get-MsolUser        -> Get-MgUser -Filter "userPrincipalName eq '...'"
      - New-MsolUser        -> New-MgUser
      - Set-MsolUser        -> Update-MgUser
      - BlockCredential     -> accountEnabled (true/false)
#>

# --- SETTINGS ---------------------------------------------------------------

$CsvPath = "C:\Git\Powershell\Data\StudentRoster.csv"

# Optional: set a temporary password for NEW accounts or for resetting existing ones
$SetPasswordForNewUsers     = $true
$ResetPasswordIfUserExists  = $false
$DefaultTempPassword        = "ChangeMe!2025"

# Optional: force account to be enabled (unblocked)
$EnsureAccountEnabled = $true

# --- FUNCTIONS --------------------------------------------------------------

function Get-StudentGradeName {
    param([string]$GradeLevel)
    switch ($GradeLevel) {
        'K' { 'Kindergarten' }
        '1' { 'First' }
        '2' { 'Second' }
        '3' { 'Third' }
        '4' { 'Fourth' }
        '5' { 'Fifth' }
        '6' { 'Sixth' }
        '7' { 'Seventh' }
        '8' { 'Eighth' }
        default { $GradeLevel } # pass-through if unexpected
    }
}

function Get-UserByUPN {
    param([Parameter(Mandatory)][string]$UserPrincipalName)

    $filter = "userPrincipalName eq '$UserPrincipalName'"
    $user = Get-MgUser -Filter $filter -ConsistencyLevel eventual -CountVariable count
    if ($user) { return $user[0] } else { return $null }
}

function Set-StudentUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$First,
        [Parameter(Mandatory)][string]$Last,
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$UserPrincipalName,
        [Parameter(Mandatory)][string]$GradeDepartment
    )

    $existing = Get-UserByUPN -UserPrincipalName $UserPrincipalName

    if ($existing) {
        Write-Host "$($existing.DisplayName) exists. Updating profile..." -ForegroundColor Cyan

        $updateBody = @{
            GivenName       = $First
            Surname         = $Last
            DisplayName     = $DisplayName
            Department      = $GradeDepartment
            JobTitle        = "Student"
        }

        if ($EnsureAccountEnabled -and -not $existing.AccountEnabled) {
            $updateBody['AccountEnabled'] = $true
        }

        try {
            Update-MgUser -UserId $existing.Id -BodyParameter $updateBody

            if ($ResetPasswordIfUserExists) {
                Write-Host "Resetting password for existing user..." -ForegroundColor Yellow
                Update-MgUser -UserId $existing.Id -PasswordProfile @{
                    ForceChangePasswordNextSignIn = $true
                    Password = $DefaultTempPassword
                }
            }

            Write-Host "$DisplayName has been edited" -ForegroundColor Yellow
            return $existing.Id
        }
        catch {
            Write-Warning "Failed to update user $UserPrincipalName: $($_.Exception.Message)"
            return $null
        }
    }
    else {
        Write-Host "$DisplayName $GradeDepartment does not exist. Creating user." -ForegroundColor Red

        $passwordProfile = $null
        if ($SetPasswordForNewUsers) {
            $passwordProfile = @{
                ForceChangePasswordNextSignIn = $true
                Password = $DefaultTempPassword
            }
        }

        $newBody = @{
            AccountEnabled    = $true
            DisplayName       = $DisplayName
            MailNickname      = ($UserPrincipalName -split '@')[0]
            UserPrincipalName = $UserPrincipalName
            GivenName         = $First
            Surname           = $Last
            Department        = $GradeDepartment
            JobTitle          = "Student"
        }
        if ($passwordProfile) { $newBody['PasswordProfile'] = $passwordProfile }

        try {
            $created = New-MgUser -BodyParameter $newBody
            Write-Host "Created: $DisplayName ($UserPrincipalName)" -ForegroundColor Green
            return $created.Id
        }
        catch {
            Write-Warning "Failed to create user $UserPrincipalName: $($_.Exception.Message)"
            return $null
        }
    }
}

# --- MAIN -------------------------------------------------------------------

# Make sure you have already connected with:
# Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"

$Roster = Import-Csv $CsvPath

foreach ($Student in $Roster) {
    $First       = $Student.'First Name'
    $Last        = $Student.'Last Name'
    $DisplayName = $Student.'Display Name'
    $Username    = $Student.'Username'
    $Grade       = Get-StudentGradeName -GradeLevel $Student.'Grade Level'

    if (-not $Username -or -not $DisplayName) {
        Write-Warning "Skipping row (missing Username or Display Name)."
        continue
    }

    Set-StudentUser -First $First -Last $Last -DisplayName $DisplayName -UserPrincipalName $Username -GradeDepartment $Grade
}
Write-Host "Done. Processed $($Roster.Count) entries from CSV." -ForegroundColor Green