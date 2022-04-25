Import-Module ExchangeOnlineManagement
Import-Module MSOnline

$Users = @{}
$Auth = @{}
$Dept = "Staff"
$Title = "Student"

$Users = Get-MsolUser
$Count = 1
foreach($User in $Users){
    #if($User.Department -eq $Dept){
        write-host $Count $User.Displayname -ForegroundColor Blue
        Write-Host "Department: " $User.Department
        Write-Host "User Object Id: " $User.ObjectId
        $Count++
        $Identity = (Get-EXOMailbox -ExternalDirectoryObjectId $User.ObjectId).Identity
        write-host "Mailbox Identity: "$Identity
        $Auth = Get-CASMailbox -Identity $Identity
        if ($Auth.ImapEnabled -eq $true){
            set-CASMailbox -Identity $Identity -ImapEnabled $false -PopEnabled $false -SmtpClientAuthenticationDisabled $true        }
        $Auth = Get-CASMailbox -Identity $Identity
        Write-Host $Identity "set to: "$Auth.ImapEnabled -ForegroundColor Green `n
    #}
}