# Get username to search mailbox permissions
$UserToFind = Read-Host "Please enter username to find mailbox permissions"

$Mailboxes = Get-exoMailbox -ResultSize Unlimited 

foreach ($mailbox in $Mailboxes){
    $Identity = (Get-EXOMailboxPermission -Identity $mailbox.Identity).Identity
    $User = (Get-EXOMailboxPermission -Identity $mailbox.Identity).User
    if($user -eq $UserToFind){
        Write-Host "Found `t" -ForegroundColor Red
        write-host "`t"$Identity -ForegroundColor Yellow
        write-host "`t"$User -ForegroundColor Blue
    
    }
    
    
}


