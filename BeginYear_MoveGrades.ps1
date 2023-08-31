$Students = Get-MsolUser | Select-Object DisplayName,UserPrincipalName,Department,title,BlockCredential
# PSCustomObject to store User data
$Person = @()

foreach($Student in $Students){
    # extract needed data
    $Display = $Student.DisplayName
    $UPN = $Student.UserPrincipalName
    $Grade = $Student.Department
    $Title = $Student.Title
    $Blocked = $Student.BlockCredential 
    # Filter for students only
    if ($Title -eq "Student"){
        # Add each student to the Person Object
        if ($Blocked -eq 'True'){
            $Status = 'Blocked'
        }
        else {
            <# Action when all if and elseif conditions are false #>
            $Status = 'Active'
        }
        $Person = $Person + [PSCustomObject]@{
            'Name' = $Display; `
            'Grade' = $Grade; `
            'UserName' = $UPN; `
            'Status' = $Status `
            -join ',';
        }
    }
}
# Verify formatting
$Person | Sort-Object Grade, Name

