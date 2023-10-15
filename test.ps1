# Get-ExecutionPolicy   
# Set-ExecutionPolicy Unrestricted–ScopeCurrentUser  
$credential = Get-Credential  
Connect-MsolService –Credential $credential  
$UserName = Read-Host"Enter the username"  
$authentication = New-Object -Type -Name Microsoft.Online.Administration.StrongAuthenticationRequirement  
$authentication.RelyingParty = "*"  
$authentication.State = "Enabled"  
$authentication.RememberDevicesNotIssuedBefore = (Get-Date)  
Get-MsolUser-UserPrincipalName$UserName | Set-MsolUser-UserPrincipalName$UserName-StrongAuthenticationRequirements$authentication A