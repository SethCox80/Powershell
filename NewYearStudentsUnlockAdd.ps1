$Roster = Import-Csv .\Data\StudentRosterCSV_8_30_2023.csv
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
    $UPrincipalName = (Get-MsolUser -SearchString $DisplayName).UserPrincipalName
    if ($UPrincipalName){
        Write-Host $DisplayName $UPrincipalName": User exits - going into grade" $Grade
        Set-MsolUser -UserPrincipalName $UPrincipalName -Department $Grade -Title "Student" -BlockCredential $false 
        write-host ((Get-MsolUser -SearchString $UPrincipalName).DisplayName)  "has been edited" -ForegroundColor Yellow
    }
    else {
        <# Action when all if and elseif conditions are false #>
        Write-host $DisplayName "Does not exist. Createing User." -ForegroundColor Red
        New-MsolUser `
            -UserPrincipalName $UPrincipalName `
            -DisplayName $DisplayName `
            -FirstName $First `
            -LastName $Last `
            -Department $Grade `
            -Title "Student"
    }
       
}