<#
Find the Department of a user and set the Title

I'm using this to make sure all teacher titles show as staff, all grades show as student, aids show as staff and so on
#>

Import-Module -Name MSOnline

$Users = Get-MsolUser | Select-Object DisplayName, userprincipalname, Department, Title

$OldDept = "Teacher"
$NewDept = "Staff"
$NewTitle = "Teacher"

foreach ($User in $Users){
    if($User.Department -like $OldDept){
    write-host $User.DisplayName, $User.Department, $User.Title
    Set-MsolUser -UserPrincipalName $User.UserPrincipalName -Department $NewDept -Title $NewTitle
    Get-MsolUser -UserPrincipalName $User.UserPrincipalName | Select-Object DisplayName, Department, Title 
    }
}
