<#

Get-RecoverableItems
   -Identity <GeneralMailboxOrMailUserIdParameter>
   [-EntryID <String>]
   [-FilterEndTime <DateTime>]
   [-FilterItemType <String>]
   [-FilterStartTime <DateTime>]
   [-LastParentFolderID <String>]
   [-ResultSize <Unlimited>]
   [-SourceFolder <RecoverableItemsFolderType>]
   [-SubjectContains <String>]
   [<CommonParameters>]

Example
Get-RecoverableItems -Identity laura@contoso.com -SubjectContains "FY17 Accounting" -FilterItemType IPM.Note -FilterStartTime "2/1/2018 12:00:00 AM" -FilterEndTime "2/5/2018 11:59:59 PM"

#>

$Name = 'wwcsoffice@wwchristianschool.org'
$Start = '02/01/2023 12:00:00 AM'
$Name = '02/14/2023 11:59:59 PM'

Get-RecoverableItems -Identity $Name -FilterStartTime $Start -FilterEndTime $End