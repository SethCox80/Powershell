Import-Module ExchangeOnlineManagement

$Name = "wwcsoffice"
$Start = "2/2/2023"

search-mailboxauditlog -identity $Name -startdate $Start -showdetails | `
    select-object LogonUserDisplayName, `
            Operation, `
            OperationResult, `
            LogonType, `
            InternalLogonType, `
            ClientIP, `
            LastAccessed `
            | Format-Table | Out-File C:\Temp\emailDelete.txt