# File: Unlock-Users-FromCsv.ps1
# Purpose: Read CSV -> find users by Username (UPN) -> set accountEnabled:$true

$CsvPath = 'C:\Git\Powershell\GraphModule\Student_MS_Info_24-46.csv'

# Ensure module & connect
if (-not (Get-Module -ListAvailable Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}
# Import-Module Microsoft.Graph
Connect-MgGraph -Scopes 'User.ReadWrite.All' -NoWelcome | Out-Null

# Import rows (expects header: SIS_ID, First_Name, Last_Name, Display_Name, Username, Password, Grade)
$rows = Import-Csv -Path $CsvPath -ErrorAction Stop

$processed = 0; $unlocked = 0; $notFound = 0

foreach ($row in $rows) {
    # Use the Username column (UPN) from your CSV
    $upn = ($row.Username).ToString().Trim()

    if ([string]::IsNullOrWhiteSpace($upn)) {
        Write-Warning "Skipping row with missing Username: $($row | ConvertTo-Json -Compress)"
        continue
    }

    try {
        # Try direct lookup by UPN, fall back to filter if needed
        $user = $null
        try {
            $user = Get-MgUser -UserId $upn -ErrorAction Stop
        } catch {
            $user = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ConsistencyLevel eventual -ErrorAction SilentlyContinue
            if ($user -is [System.Collections.IEnumerable]) { $user = $user | Select-Object -First 1 }
        }

        if (-not $user) {
            Write-Warning "Not found: $upn"
            $notFound++; continue
        }

        # "Unlock" = enable the account
        if ($user.AccountEnabled -ne $true) {
            Update-MgUser -UserId $user.Id -AccountEnabled:$true -ErrorAction Stop
            Write-Host "Unlocked: $($user.DisplayName) <$upn>"
            $unlocked++
        } else {
            Write-Host "Already enabled: $($user.DisplayName) <$upn>"
        }

        $processed++
    } catch {
        Write-Error "Error processing $upn : $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Summary  ->  Processed: $processed | Unlocked: $unlocked | Not found: $notFound"
