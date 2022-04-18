Import-Module ExchangeOnlineManagement
Import-Module MSOnline

$Users = @{}
$Auth = @{}

$Users = Get-MsolUser

$Count = 1

foreach($User in $Users){
    if($User.Department -eq "Staff"){
        write-host $Count " "$User.Displayname -ForegroundColor Blue
        Write-Host $User.Department
        Write-Host $User.ObjectId
        $Count = $Count + 1
        $Identity = (Get-EXOMailbox -ExternalDirectoryObjectId $User.ObjectId).Identity
        write-host "Mailbox Identity "$Identity
        $Auth = Get-CASMailbox -Identity $Identity
        if ($null -eq $Auth.SmtpClientAuthenticationDisabled){
            set-CASMailbox -Identity $Identity -SmtpClientAuthenticationDisabled $true
        }
        $Auth = Get-CASMailbox -Identity $Identity
        Write-Host $Identity "set to: "$Auth.SmtpClientAuthenticationDisabled -ForegroundColor Green `n
    }
}