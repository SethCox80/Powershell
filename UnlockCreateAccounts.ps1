$NewUsers = Import-Csv C:\git\Powershell\Data\StudentRoster_9_4_2022.xls.csv

foreach ($User in $NewUsers) {
    $Displayname = $User.Displayname
    $UPN = $User.UserPrincipalName
    switch ($User.Grade) {
        'K' { $dept = 'Kindergarten' }
        '1' { $dept = 'First' }
        '2' { $dept = 'Second' }
        '3' { $dept = 'Third' }
        '4' { $dept = 'Fourth' }
        '5' { $dept = 'Fifth' }
        '6' { $dept = 'Sixth' }
        '7' { $dept = 'Seventh' }
        '8' { $dept = 'Eighth' }
    }
    if (get-msoluser -SearchString $Displayname) {
        $Student = Get-MsolUser -SearchString $Displayname | Select-Object *
        $ObjID = $Student.ObjectId
        $StudUserPrincName = $Student.UserPrincipalName
        $CheckBlock = $Student.BlockCredential
        Write-Host $StudUserPrincName $Displayname "Found" -foreground yellow
        if ($CheckBlock = $true) {
            Set-MsolUser -ObjectId $ObjID `
                -BlockCredential $false `
                -Department $dept `
                -Title "Student"
        }
        write-host $Displayname "Username:" $StudUserPrincName "in grade" $dept "shows grade" $Student.Department "and is blocked (true/false)" $Student.BlockCredential


    }
    else {
        write-host $Displayname "Not Found" -ForegroundColor Red
        New-MsolUser -UsageLocation "US" `
            -UserPrincipalName $UPN `
            -DisplayName $Displayname `
            -FirstName $User.First `
            -LastName $User.Last `
            -Department $dept `
            -Title "Student" `
            -LicenseAssignment "wwchristianschoolorg:ENTERPRISEPACKPLUS_STUUSEBNFT"
        
    }
    Set-MsolUserPassword -UserPrincipalName $User.UserPrincipalName -NewPassword $User.Password -ForceChangePassword $false | Out-Null
}