param(
    [Parameter(Mandatory = $true)][string]$CsvPath,
    [string]$DefaultDomain = "wwchristianschool.org"   # e.g. "wwchristianschool.org" (optional if Username already has @domain)
)

# --- Module / Connect ---
if (-not (Get-Module -ListAvailable Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}
# Import-Module Microsoft.Graph
Connect-MgGraph -Scopes 'User.ReadWrite.All', 'Directory.ReadWrite.All' -NoWelcome | Out-Null

# --- Password helper ---
function New-StrongPassword {
    param([int]$Length = 14)

    $lower = 'abcdefghjkmnpqrstuvwxyz'
    $upper = 'ABCDEFGHJKMNPQRSTUVWXYZ'
    $digit = '23456789'
    $spec = '@#$%!?*-+='

    # Ensure at least one of each category
    $req = @(
        $lower[(Get-Random -Min 0 -Max $lower.Length)]
        $upper[(Get-Random -Min 0 -Max $upper.Length)]
        $digit[(Get-Random -Min 0 -Max $digit.Length)]
        $spec[(Get-Random -Min 0 -Max $spec.Length)]
    )

    $pool = ($lower + $upper + $digit + $spec).ToCharArray()
    $remain = for ($i = 0; $i -lt ($Length - $req.Count); $i++) { $pool[(Get-Random -Min 0 -Max $pool.Length)] }
    -join (Get-Random -InputObject ($req + $remain) -Count $Length)
}

# --- Read CSV (ensure unique headers!) ---
$rows = Import-Csv -Path $CsvPath -ErrorAction Stop

$results = New-Object System.Collections.Generic.List[object]

foreach ($row in $rows) {
    $FirstName = ($row.First_Name).ToString().Trim()
    $LastName = ($row.Last_Name).ToString().Trim()
    $DisplayName = ($row.Display_Name).ToString().Trim()
    $RawUser = ($row.Username).ToString().Trim()
    $Department = ($row.Grade).ToString().Trim()
    $Title = "Student"
    if ([string]::IsNullOrWhiteSpace($RawUser)) {
        $results.Add([pscustomobject]@{
                Username = $null; FirstName = $FirstName; LastName = $LastName; Grade = $Department; Action = 'Skip'; Status = 'No Username'
            })
        continue
    }

    # Build UPN
    $upn = if ($RawUser -like '*@*') { $RawUser } elseif ($DefaultDomain) { "$RawUser@$DefaultDomain" } else { $RawUser }
    $mailNick = ($RawUser -split '@')[0]

    # Decide password
    $CsvPassword = ($row.Password).ToString()
    $Password = if ([string]::IsNullOrWhiteSpace($CsvPassword)) { New-StrongPassword 14 } else { $CsvPassword }

    try {
        # Does the user already exist?
        $existing = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue

        if ($existing) {
            # --- UPDATE ---
            $updateParams = @{
                UserId      = $upn
                DisplayName = $DisplayName
                Department  = $Department
            }
            if ($Title) { $updateParams['JobTitle'] = $Title }

            Update-MgUser @updateParams -ErrorAction Stop

            # Only reset password if CSV provided a password (don’t surprise-reset)
            if (-not [string]::IsNullOrWhiteSpace($CsvPassword)) {
                Update-MgUser -UserId $upn -PasswordProfile @{
                    ForceChangePasswordNextSignIn = $false
                    Password                      = $Password
                } -ErrorAction Stop
            }

            $results.Add([pscustomobject]@{
                    Username = $upn; FirstName = $FirstName; LastName = $LastName; Grade = $Department; Password = $Password; Action = 'Update'; Status = 'OK'
                })
        }
        else {
            # --- CREATE ---
            New-MgUser -AccountEnabled:$true `
                -DisplayName $DisplayName `
                -MailNickname $mailNick `
                -UserPrincipalName $upn `
                -Department $Department `
                -JobTitle $Title `
                -PasswordProfile @{
                ForceChangePasswordNextSignIn = $false
                Password                      = $Password
            } -ErrorAction Stop

            $results.Add([pscustomobject]@{
                    Username = $upn; FirstName = $FirstName; LastName = $LastName; Grade = $Department; Password = $Password;Action = 'Create'; Status = 'OK'
                })
            
        }
        Write-Host $upn $FirstName $LastName $Department $Password
    }
    catch {
        $results.Add([pscustomobject]@{
                Username = $upn; FirstName = $FirstName; LastName = $LastName; Grade = $Department; Action = 'Error'; Status = $_.Exception.Message
            })
    }
}

# --- Export run results ---
$results | Export-Csv -Path ".\AccountUpdateCreate.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Done. Results written to .\AccountUpdateCreate.csv"
