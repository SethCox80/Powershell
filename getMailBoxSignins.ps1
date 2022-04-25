$mailboxes = Get-Mailbox -ResultSize Unlimited
$mailboxes | ForEach-Object {
    $mbx = $_
    $mbs = Get-MailboxStatistics -Identity $mbx.UserPrincipalName | Select-Object LastLogonTime
    if ($null -eq $mbs.LastLogonTime) {
        $lt = "Never Logged In"
    }
    else {
        $lt = $mbs.LastLogonTime 
    }
 
    New-Object -TypeName PSObject -Property @{ 
        UserPrincipalName = $mbx.UserPrincipalName
        LastLogonTime     = $lt 
    }
}