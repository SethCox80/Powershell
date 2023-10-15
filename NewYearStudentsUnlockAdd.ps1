$Roster = Import-Csv .\Data\StudentRosterCSV_9_9_2023.csv
foreach ($Student in $Roster) {
    $First = $Student.'First Name'
    $Last = $Student.'Last Name'  
    $DisplayName = $Student.'Display Name'
    $Username= $Student.'Username'
    switch ($Student.'Grade Level') {
        'K' { $Grade = 'Kindergarten' }
        '1' { $Grade = 'First' }
        '2' { $Grade = 'Second' }
        '3' { $Grade = 'Third' }
        '4' { $Grade = 'Fourth' }
        '5' { $Grade = 'Fifth' }
        '6' { $Grade = 'Sixth' }
        '7' { $Grade = 'Seventh' }
        '8' { $Grade = 'Eighth' }
    }
    $NameToSearch = (Get-MsolUser -SearchString $DisplayName).UserPrincipalName
    if ($NameToSearch){
        Write-Host $DisplayName $Username": User exits - going into grade" $Grade
        Set-MsolUser -UserPrincipalName $NameToSearch -Department $Grade -Title "Student" -BlockCredential $false
            # <# Set-MsolUserPassword -ObjectId <Guid>
            #         [-NewPassword <String>]
            #         [-ForceChangePassword <Boolean>]
            #         [-ForceChangePasswordOnly <Boolean>]
            #         [-TenantId <Guid>]
            #         [<CommonParameters>]
            # #>
        Set-MsolUserPassword -UserPrincipalName $Username -NewPassword $Student.Password -ForceChangePassword $false
        write-host $NameToSearch "has been edited" -ForegroundColor Yello 
                
        }
    else {
        Write-host $DisplayName $Grade "Does not exist. Createing User." -ForegroundColor Red
        New-MsolUser `
            -UserPrincipalName $Username `
            -DisplayName $DisplayName `
            -FirstName $First `
            -LastName $Last `
            -Department $Grade `
            -Title "Student"
            # -LicenseAssignment "wwchristianschoolorg:ENTERPRISEPACKPLUS_STUUSEBNFT"
    }
       
}