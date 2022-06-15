$Accounts = Get-MsolUser | Select-Object DisplayName, userprincipalname, Department, Title, BlockCredential


foreach ($Account in $Accounts) { # This will lock all student accounts that are not locked
 
    $Name = $Account.displayname
    $UserName = $Account.UserPrincipalName
    $Title = $Account.Title
    $Grade = $Account.Department
    $IsBlocked = $Account.BlockCredential
    
    if ($Title -eq "Student") { #Show all student accounts
        write-host $Name " :: "-NoNewline -ForegroundColor Yellow
        write-host $UserName " :: " -NoNewline -ForegroundColor Blue
        write-host $Title " :: " -NoNewline -ForegroundColor Yellow
        write-host $Grade " :: "-NoNewline -ForegroundColor Red
        write-host "Is Blocked:", $IsBlocked -ForegroundColor Cyan
        # Only look for those that are unlocked (not blocked)
        if ($IsBlocked -eq $false){ # $true = locked, $false = unlocked 
            Set-MsolUser -UserPrincipalName $UserName -BlockCredential $true # $true = locked, $false = unlocked
            write-host $Name ": account is now locked!!" -ForegroundColor Green
        }  
    }
}

