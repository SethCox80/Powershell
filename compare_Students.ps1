

$CurrentUsers = Get-MsolUser | Select-Object displayname,userprincipalname,title,department,blockcredential
$Student_List = @()

foreach ($User in $CurrentUsers){
    if ($User.Department = 'student'){
        $Student_List = $Student_List + $User}
}

# Export to CSV
$csvFilePath = ".\Powershell\currentusers.csv"
$CurrentUsers | Export-Csv -Path $csvFilePath -NoTypeInformation
