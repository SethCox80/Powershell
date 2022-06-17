#Import-Module AzureAD
#connect-azuread 

$Students = @{}
$Students = Get-Msoluser | Select-Object Displayname, userprincipalname, Title, Department, BlockCredential

foreach ($Student in $Students) {
    $Name = $Student.Displayname
    $Username = $Student.userprincipalname
    $Grade = $Student.Department
    $Title = $Student.Title
    $IsBlocked = $Student.BlockCredential

    If ($Title -eq 'Student') {
        write-host $Name, "grade" $Grade, "is blocked: " $IsBlocked -ForegroundColor Yellow
        Get-AzureADUser -SearchString $Name | Revoke-AzureADUserAllRefreshToken
        Write-Warning "Session Revoked for $Username"
    }
            
}