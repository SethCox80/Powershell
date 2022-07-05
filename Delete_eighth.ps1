<#

Incomplete project

#>

$Users  = get-msoluser 
$Eight_Deleted = @()

foreach ($User in $Users){
    $First = $User.FirstName
    $Last = $User.LastName
    $DisplayName = $User.displayname
    $Title = $User.Title
    $Student = $User.userprincipalname
    $ObjID = $User.objectid
    if ($User.Department -eq 'eighth'){
        write-warning $Student 'will be deleted'
        Set-MsolUser -ObjectID $ObjID -BlockCredential $true
        $IsLocked = (get-msoluser -userprincipalname $Student).blockcredential 
        if ($IsLocked -eq $true){
            write-host '++ '$Student 'is now locked' -foregroundcolor Green
        }
        else {
            write-host '--   '$Student 'is still unlocked' -foregroundcolor Red
        }
        $Eight_Deleted = $Eight_Deleted + [PSCustomObject] @{
            First_Name          = $First;
            Last_Name           = $Last;
            Display_Name        = $DisplayName;
            User_Principal_Name = $Username;
            Title               = $Title;
            Department          = $Department;
            Grade               = $Grade
            Is_Blocked          = $IsBlocked
        }
    }
    
}

$TestPath = test-path -path 'c:\temp'
if ($TestPath -ne $true) {
    New-Item -ItemType directory -Path 'c:\temp' | Out-Null
    write-Host  'Creating directory to write file to c:\temp. Your file is uploaded as Users.csv'
}
else { Write-Host "Your file has been uploaded to c:\temp as 'Eight_Deleted.csv'" }
$Eight_Deleted | Export-Csv c:\temp\Eight_Deleted.csv -notypeinformation