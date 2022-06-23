<#

Get Users status and export to csv

#>

$Users = Get-MsolUser
$UserList = @()

foreach ($User in $Users) {
    $First = $User.FirstName
    $Last = $User.LastName
    $DisplayName = $User.displayname
    $Username = $User.userprincipalname
    $Title = $User.Title
    $Department = $User.Department
    $Grade = switch ($User.Department) {
        'Kindergarten' { 'K' }
        'First' { 1 }
        'Second' { 2 }
        'Third' { 3 }
        'Fourth' { 4 }
        'Fifth' { 5 }
        'Sixth' { 6 }
        'Seventh' { 7 }
        'Eighth' { 8 }
        Default { "Not a student" }
    }
    $IsBlocked = $User.BlockCredential
    $UserList = $UserList + [PSCustomObject]@{
        First_Name          = $First;
        Last_Name           = $Last;
        Dispaly_Name        = $DisplayName;
        User_Principal_Name = $Username;
        Title               = $Title;
        Department          = $Department;
        Grade               = $Grade
        Is_Blocked          = $IsBlocked
    }
}

$TestPath = test-path -path 'c:\temp'
if ($TestPath -ne $true) {
    New-Item -ItemType directory -Path 'c:\temp' | Out-Null
    write-Host  'Creating directory to write file to c:\temp. Your file is uploaded as Users.csv'
}
else { Write-Host "Your file has been uploaded to c:\temp as 'Users.csv'" }
$UserList | Export-Csv c:\temp\Users.csv -notypeinformation