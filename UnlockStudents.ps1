$Users = Get-MsolUser

foreach ($user in $Users){
    if ($User.Title -eq 'Student'){
        Write-Host $user.DisplayName "is a Student"
        $Grade = switch ($User.Department) {
            'Kindergarten' { 'K' }
            'First' { 1 }
            'Second' { 2 }
            'Third' { 3 }
            'Fourth' { 4 }
            'Fifth' { 5 }
            'Sixth' { 6 }
            'Seventh' { 7 }
            'Eighth' { 8 }
            Default { "Not a student" }
        }
        if ($Grade -gt 3 -and $Grade -ne 'K'){
            Write-Host "`t Checking for Lock" -ForegroundColor Green
            if ($User.BlockCredential -eq 'True'){
                Set-MsolUser -UserPrincipalName $User.UserPrincipalName -BlockCredential $false
                write-host "   -- Account Unlocked"
            }
            else{
                Write-Host "`t ++ Account already enabled"
            }
        }
        else{
            Write-Host "`t ## Grade too low - Will not unlock student. Confirm locked account--" -ForegroundColor Red
            Set-MsolUser -UserPrincipalName $User.UserPrincipalName -BlockCredential $true
            write-host "`t -- User is blocked:"(Get-MsolUser -UserPrincipalName $User.UserPrincipalName).blockcredential
        }
    }
    else{
        Write-Host $User.DisplayName "is not a student" -ForegroundColor Yellow
    }
}