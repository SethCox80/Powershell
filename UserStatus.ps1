<#
Get Student Sign in status or
Set sign in status
Export Status of all users to CSV
#>

$Users = Get-Msoluser | Select-Object *
$Student = @()

foreach ($User in $Users) {
    $Name = $User.DisplayName
    $UserName = $User.Userprincipalname
    $Grade = $User.Department
    $IsBlocked = $User.BlockCredential
    $Title = $User.Title
    if ($Title -eq 'Student') {
        switch ($Grade) {
            "Kindergarten" { $GradeNum = 'K' }
            "First" { $GradeNum = 1 }
            "Second" { $GradeNum = 2 }
            "Third" { $GradeNum = 3 }
            "Fourth" { $GradeNum = 4 }
            "Fifth" { $GradeNum = 5 }
            "Sixth" { $GradeNum = 6 }
            "Seventh" { $GradeNum = 7 }
            "Eighth" { $GradeNum = 8 }
            Default { $GradeNum = 'NoStudent' }
        }
        Write-Host $Name $Username "Grade:"$Grade "-" $GradeNum  "Is blocked: " $IsBlocked -ForegroundColor Yellow
        if ($GradeNum -ge 4 -and $GradeNum -ne 'K') {
            #Set-MsolUser -UserPrincipalName $UserName -BlockCredential $false
            #Get-MsolUser -UserPrincipalName $UserName | Select-Object Userprincipalname, DisplayName, BlockCredential 
        }
        
    #Export Status to CSV
    }
    if ($IsBlocked -eq "True") {
        $Status = 'Blocked'
    }
    else {
        $Status = 'Enabled'
    }
    $Student = $Student + [PSCustomObject]@{'Display Name' = $Name; `
                                            'User Name' = $UserName; `
                                            'Title (Staff, student, etc)' = $Title
                                            'Grade (if Student)' = $Grade; `
                                            'Account Status' = $Status `
                                             -join ', '; }

    
}

$TestPath = test-path -path 'c:\temp'
if ($TestPath -ne $true) {
    New-Item -ItemType directory -Path 'c:\temp' | Out-Null
    write-Host  'Creating directory to write file to c:\temp. Your file is uploaded as StudentStatus.csv'
}
else { Write-Host "Your file has been uploaded to c:\temp as 'StudentStatus.csv'" }
$Student | Export-Csv c:\temp\StudentStatus.csv