<# 
.SYNOPSIS
  Dry-run checker for your user CSV. NO writes to Graph.
.PARAMETERS
  -CsvPath        Path to input CSV (expects at least Display_Name, Username; others optional)
  -DefaultDomain  Used when Username doesn't include @domain
  -OutCsv         Optional path to export the results (otherwise prints a table)
#>

param(
  [Parameter(Mandatory=$true)][string]$CsvPath,
  [string]$DefaultDomain = "school.org",
  [string]$OutCsv = ""
)

# Ensure Graph is available; connect with read-only scope for users
if (-not (Get-Module -ListAvailable Microsoft.Graph)) { Install-Module Microsoft.Graph -Scope CurrentUser -Force }

Connect-MgGraph -Scopes 'User.Read.All' -NoWelcome | Out-Null

# Load CSV
$rows = Import-Csv -Path $CsvPath -ErrorAction Stop

# Helper to normalize UPN & alias
function Get-UpnAndAlias {
    param([string]$Username, [string]$DefaultDomain)
    if ([string]::IsNullOrWhiteSpace($Username)) { return $null }
    if ($Username -notlike "*@*") { $upn = "$Username@$DefaultDomain" } else { $upn = $Username }
    [pscustomobject]@{
        UPN       = $upn.Trim()
        MailNick  = $upn.Split('@')[0]
    }
}

$results = foreach ($r in $rows) {
    $displayName = $r.Display_Name
    $userRaw     = $r.Username
    $dept        = $r.Department
    $title       = $r.Title

    $ids = Get-UpnAndAlias -Username $userRaw -DefaultDomain $DefaultDomain
    if ($null -eq $ids) {
        [pscustomobject]@{
            DisplayName = $displayName
            Username    = $userRaw
            UPN         = ""
            Exists      = $false
            Action      = "Skip (missing Username)"
            Notes       = "No Username in CSV row"
        }
        continue
    }

    $upn = $ids.UPN

    # Try read the user (no write operations)
    try {
        $u = Get-MgUser -UserId $upn -ErrorAction Stop
        # If found, report what we'd update (no change is made)
        [pscustomobject]@{
            DisplayName = $displayName
            Username    = $userRaw
            UPN         = $upn
            Exists      = $true
            Action      = "Would Update"
            CurrentDept = $u.Department
            NewDept     = $dept
            CurrentJob  = $u.JobTitle
            NewJob      = $title
            Notes       = "No changes performed (check-only)"
        }
    }
    catch {
        # Not found -> would create
        [pscustomobject]@{
            DisplayName = $displayName
            Username    = $userRaw
            UPN         = $upn
            Exists      = $false
            Action      = "Would Create"
            CurrentDept = ""
            NewDept     = $dept
            CurrentJob  = ""
            NewJob      = $title
            Notes       = "No changes performed (check-only)"
        }
    }
}

# Output
if ($OutCsv) {
    $results | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding UTF8
    Write-Host "Check complete. Results saved to: $OutCsv"
} else {
    $results | Sort-Object Exists, UPN | Format-Table -AutoSize
}
