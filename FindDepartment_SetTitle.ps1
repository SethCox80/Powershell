<#
Find the Department of a user and set the Title

I'm using this to make sure all teacher titles show as staff, all grades show as student, aids show as staff and so on
#>

Import-Module -Name MSOnline

$Users = Get-MsolUser | Select-Object DisplayName, Department, userprincipalname, Title

Write-Host $Users.DisplayName
Write-Host