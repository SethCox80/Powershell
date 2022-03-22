#
# if (($PSVersionTable.PSVersion).Major -gt 5){Powershell}
# Pause
# Import-Module -name MSOnline
# Connect-Msolservice

#Functions

#  “^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&-+=()!])(?=\\S+$).{8, 20}$”
#  "^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)$"

#******************************************************************************************************
function YesorNo() {
    do {
        $Ans = (read-host "Y or N").ToUpper()         
        if ($Ans -match "^Y|N$") {
            $Valid = $true
        }
        else {
            write-host "You answered '$Ans'. Please Enter " -ForegroundColor Red -NoNewline
            $Valid = $false
        }
    }while ($Valid -eq $false)
    if ($Ans -eq "Y") {
        return $true
    }
    else {
        return $false
    }
}
#******************************************************************************************************
function ValidateName {
    param (
        [Parameter()]
        [String]
        $NameToCheck
    )
    if ($NameToCheck -match "^[A-Za-z]+$") {
        # Will retrun only if the Name is Valid - No numbers, spaces, or special characters        
        return $NameToCheck
    }
    Else {
        write-host "Invalid name. No spaces, numbers, or special characters. " -NoNewline
        ValidateName (read-Host "Please Enter a valid name ")
    }    
}
#******************************************************************************************************
function MainMenu() {
    WRite-host "*******************************************************************" -ForegroundColor Green
    Write-Host "*       Create a new User:                                        *" -ForegroundColor Green
    Write-Host "*       1. Student Account                                        *" -ForegroundColor Green
    Write-Host "*       2. Employee Account                                       *" -ForegroundColor Green
    Write-Host "*       3. End Program (Answer 'N' to 'Create another User?')     *" -ForegroundColor Green
    Write-Host "*                                                                 *" -ForegroundColor Green
    WRite-host "*******************************************************************" -ForegroundColor Green
}
#******************************************************************************************************
function ConfirmInfo {
    #Confirm Information
    Write-Host "-------------------------------------------------------------------"
    if ($NewOpt -eq 1) { Write-Host "Student's name to be added:"$First, $Last -ForegroundColor Yellow } #If new user is student
    else { Write-Host "Employee's name to be added:"$First, $Last -ForegroundColor Yellow } #if new user is employee
    Write-Host "Display Name: "$DisplayNm -ForegroundColor Blue
    if (!$IsEmp) { Write-Host "Grade of new Student"$Grade -ForegroundColor Green } #Should skip this print line if Employee
    Write-Host "Principal User Name: "$PrincUserName -ForegroundColor Blue
    If (!$IsEmp) { Write-Host "Password will be entered at next Prompt" -ForegroundColor Red }
    elseif ($IsEmp) { Write-Host "Password set to 'Start1234' and force change at first login! " -ForegroundColor Red } 
    Write-Host "--------------------------------------------------------------------`n"
}
#******************************************************************************************************
function NewStudent {
    Do {
        $IsEmp = $false
        Clear-Host
        MainMenu #Call Menu
        #Get Student Name
        Write-Host "Please enter name with no spaces, numbers, or characters."
        $First = ValidateName(read-Host "Please enter first name ")
        $Last = ValidateName(read-Host "Please enter last name ")
        #Set StudentId Number for username formation
        Do {
            $StudentNum = Read-Host "Enter Student number for new Student (####)"
            if ($StudentNum -match "^\d{4}$") {
                #checks for 4 digits - numbers only
                $NumIsRight = $true
            }
            else {
                Write-host "Please enter a 4 digit number - numbers only"
                $NumIsRight = $false
            }
        } while (!$NumIsRight)
        #Get Student Grade
        Do {
            $Grade = Read-Host "Enter Student's grade (4-8 use numeral)" #Only 4-8 grade have ACTIVE AND UNLOCKED O365 Accounts>
            if ($Grade -match "^[4-8]{1}$") {
                $GradeCheck = $true
            }
            else {
                Write-host "Please enter a grade number 4-8" -ForegroundColor Red
                $GradeCheck = $false
            }
        } while (!$GradeCheck) 
        $PrincUserName = $Last + $StudentNum.Substring(1, 3) + "<@EmailDomain>"
        $DisplayNm = $First, $Last
        Switch ($Grade) {
            #Dept is used for the grade in Student contact info
            4 { $Dept = "Fourth" }
            5 { $Dept = "Fifth" }
            6 { $Dept = "Sixth" }
            7 { $Dept = "Seventh" }
            8 { $Dept = "Eighth" }
        }
        ConfirmInfo
        write-host "Is this correct? " -NoNewline
        $Ans = YesorNo
        return $IsEmp
    } while (!$Ans)
    Clear-Host
    MainMenu #Call Menu
    $PassWD = Read-Host "Please enter Desired password for $DisplayNm "
    $Force = $false
    # New-MsolUser `
    #     -DisplayName "$DisplayNm" `
    #     -FirstName "$First" `
    #     -LastName "$Last" `
    #     -UserPrincipalName "$PrincUserName" `
    #     -Password "$PassWD" `
    #     -ForceChangePassword $Force `
    #     -Title "Student" `
    #     -Department "$Dept" `
    #     -LicenseAssignment "wwchristianschoolorg:ENTERPRISEPACKPLUS_STUUSEBNFT" -UsageLocation US
     
}
#******************************************************************************************************
function NewEmployee {
    Do {
        #Get Employee Name
        $IsEmp = $true
        Clear-Host
        #Call Menu   
        MainMenu
        #Get Employee Name         
        Write-Host "Please enter name with no spaces, numbers, or characters."
        $First = ValidateName(read-Host "Please enter first name ")
        $Last = ValidateName(read-Host "Please enter last name ")
        $PrincUserName = $First.substring(0, 1) + $Last + "@wwchristianschool.org"
        $DisplayNm = $First, $Last
        Clear-Host
        MainMenu
        ConfirmInfo
        write-host "Is this correct? " -NoNewline
        $Ans = YesorNo
    } while (!$Ans)
    $StTitle = "Teacher"
    $Force = $true
    # New-MsolUser `
    #     -DisplayName "$DisplayNm" `
    #     -FirstName "$First" `
    #     -LastName "$Last" `
    #     -UserPrincipalName "$PrincUserName" `
    #     -Password "Start!1234" `
    #     -ForceChangePassword $Force `
    #     -Title "$StTitle" `
    #     -Department "$Dept" `
    #     -LicenseAssignment "wwchristianschoolorg:STANDARDWOFFPACK_FACULTY" -UsageLocation US
     
}
#******************************************************************************************************

#Start Porgram
Do {
    #Call Menu
    do {
        #ensures valid option
        Clear-Host
        MainMenu 
        $NewOpt = read-host "Please Select and option 1 or 2 "
        if ($NewOpt -match "^[1-3]{1}$") {
            # Ensures option matches the pattern 1-2 and is expandable to any number
            $ValidOpt = $true 
        }
        else {
            write-host "You entered '$NewOpt' Please enter a vlaid option. " -ForegroundColor Red -NoNewline
            Pause
            $ValidOpt = $false
        }
    }while (!$ValidOpt)
    switch ($NewOpt) {
        #Expandable with new functions added
        1 { NewStudent }
        2 { NewEmployee }
    }
    Write-Host "Create another User? " -NoNewline
    $Ans = YesorNo
} while ($Ans)
write-host "Ending Script" -ForegroundColor Red
Pause
clear-host
