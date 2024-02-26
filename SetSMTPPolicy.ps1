$Users = @{}
$Auth = @{}
# $Dept = "Staff"
# $Title = "Student"

$Users = Get-MsolUser
$Count = 1
foreach($User in $Users){

    write-host $Count $User.Displayname -ForegroundColor Blue
    Write-Host $user.UserPrincipalName
    Write-Host "Department: " $User.Department
    Write-Host "User Object Id: " $User.ObjectId
    $Count++
    if($User.BlockCredential -eq $false){
        if($Identity = (Get-EXOMailbox -ExternalDirectoryObjectId $User.ObjectId).Identity){   
            write-host "Mailbox Identity: "$Identity
            $Auth = Get-CASMailbox -Identity $Identity
            if($Auth.ImapEnabled -eq $true){
                set-CASMailbox -Identity $Identity -ImapEnabled $false -PopEnabled $false -SmtpClientAuthenticationDisabled $true        
                
                $Auth = Get-CASMailbox -Identity $Identity
            }else {
                <# Action when all if and elseif conditions are false #>
                write-host $User "is disabled and may not have a mailbox"
            }
        }
       
    }
    # Write-Host $Identity "set to: "$Auth.ImapEnabled -ForegroundColor Green `n

}