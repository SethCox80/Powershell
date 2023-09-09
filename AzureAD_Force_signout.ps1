# Import-Module AzureAD
# connect-azuread 

$Users = @{}
$Users = Get-Msoluser | Select-Object Displayname, userprincipalname, Title, Department, BlockCredential

foreach ($User in $Users) {
    $Name = $User.Displayname
    $Username = $User.userprincipalname
    $Grade = $User.Department
    $Title = $User.Title
    $IsBlocked = $Student.BlockCredential

    If ($Title -eq 'Student') {
        write-host $Name, "grade" $Grade, "is blocked: " $IsBlocked -ForegroundColor Yellow
        Get-AzureADUser -SearchString $Name | Revoke-AzureADUserAllRefreshToken
        Write-Warning "Session Revoked for $Username"
    }
            
}