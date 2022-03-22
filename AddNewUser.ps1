#
Import-Module -name MSOnline

#Global
$ValAns = ("y", "Y", "n", "N")
$Grade = ""

#Funcions
function FirstMenu() {
    Clear-Host
    WRite-host "****************************************************************************************************"
    Write-Host "*       Create a new User:                                                                         *"
    Write-Host "*       1. Student Account                                                                         *"
    Write-Host "*       2. Employee Account                                                                        *"
    Write-Host "*                                                                                                  *"
    WRite-host "****************************************************************************************************"
}

function ConfirmInfo {
    #Confirm Information
    Write-Host "-------------------------------------------------------------------"
    if ($NewOpt -eq 1) { Write-Host "Student's name to be added:"$First, $Last -ForegroundColor Yellow } #If new user is student
    else { Write-Host "Employee's name to be added:"$First, $Last -ForegroundColor Yellow } #if new user is emplyee
    Write-Host "Display Name: "$DisplayNm -ForegroundColor Blue
    if ($Grade -ne "") { Write-Host "Grade of new Student"$Grade -ForegroundColor Yellow } #Should skip this print line if Employee
    Write-Host "Principal User Name: "$PrincipalUserName -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------`n"
}
Do {
    function NewStudent {
        Do {
            Clear-Host
            FirstMenu #Call Menu
            Write-Host "Enter Data"
            #Get Student Name
            $Last = Read-Host "What is new student's last name "
            $First = Read-Host "What is new student's first name "
            Write-Host "`nStudents name to be added:"$First, $Last -ForegroundColor Red

            #Get Student Grade
            Do {
                $Grade = Read-Host "`nEnter Student's grade (4-8 use numeral)"
                if (($Grade -ge 4) -and ($Grade -le 8)) {
                    Write-host "Correct"
                    $GradeCheck = $false
                }
                else {
                    Write-host "Please enter a grade number 4-8" -ForegroundColor Red
                    $GradeCheck = $true
                }

            } while ($GradeCheck) 

            #Set User Values
            Do {
                $StudentNum = Read-Host "`nEnter Student number for new Student (####)"
                if ($StudentNum -match "^\d{4}$") {
                    #checks for 4 digits - numbers only
                    $NumIsRight = $true
                }
                else {
                    Write-host "Please enter a 4 digit number - numbers only"
                    $NumIsRight = $false
                }

            } while ($StudentNum.Length -ne 4 -or $NumIsRight -eq $false )

            $PrincipalUserName = $Last + $StudentNum.Substring(1, 3) + "@wwchristianschool.org"
            $DisplayNm = $First, $Last
            Switch ($Grade) {
                4 { $Dept = "Fourth" }
                5 { $Dept = "Fifth" }
                6 { $Dept = "Sixth" }
                7 { $Dept = "Seventh" }
                8 { $Dept = "Eighth" }
            }
            ConfirmInfo
            $AnsCheck = $true
            while ($AnsCheck) {
                #Will Loop until Valid answer is chosen
                $Ans = Read-Host "Satisfied (Y or N)"
                if ($Ans -in $ValAns) {
                    $AnsCheck = $false #Will break Answer Check loop
                }         
                else {
                    Write-Host "(Y or N) you endered '$Ans'"
                }
            }
            if ($Ans -in ("Y", "y")) {
                $DoLoop = $false
            }
            else {
                $DoLoop = $true
            } 
        } while ($DoLoop)

        Pause
        Clear-Host

        FirstMenu #Call Menu
        $PassWD = Read-Host "Please enter tha password for $DisplayNm "
        $Force = $false
        # New-MsolUser `
        #     -DisplayName "$DisplayNm" `
        #     -FirstName "$First" `
        #     -LastName "$Last" `
        #     -UserPrincipalName "$PrincipalUserName" `
        #     -Password "$PassWD" `
        #     -ForceChangePassword $Force `
        #     -Title "Student" `
        #     -Department "$Dept" `
        #     -LicenseAssignment "wwchristianschoolorg:ENTERPRISEPACKPLUS_STUUSEBNFT" -UsageLocation US

        Pause
    }
    function NewEmployee {
        Do {
            Write-Host "Enter Data"
            #Get Student Name
            $Last = Read-Host "What is new student's last name "
            $First = Read-Host "What is new student's first name "
            $PrincipalUserName = $First.substring(0, 1) + $Last + "@wwchristianschool.org"
            $DisplayNm = $First, $Last

            FirstMenu
            ConfirmInfo

            $AnsCheck = $true
            while ($AnsCheck) {
                #Will Loop until Valid answer is chosen
                $Ans = Read-Host "Satisfied with information and create user? (Y or N)"
                if ($Ans -in $ValAns) {
                    $AnsCheck = $false #Will break Answer Check loop
                }         
                else {
                    Write-Host "(Y or N) you endered '$Ans'"
                }
            }
            if ($Ans -in ("Y", "y")) {
                $DoLoop = $false
            }
            else {
                $DoLoop = $true
            } 
        } while ($DoLoop)
        $StTitle = "Teacher"
        # $Force = $true
        # New-MsolUser `
        #     -DisplayName "$DisplayNm" `
        #     -FirstName "$First" `
        #     -LastName "$Last" `
        #     -UserPrincipalName "$PrincipalUserName" `
        #     -Password "Start!1234" `
        #     -ForceChangePassword $Force `
        #     -Title "$StTitle" `
        #     -Department "$Dept" `
        #     -LicenseAssignment "wwchristianschoolorg:STANDARDWOFFPACK_FACULTY" -UsageLocation US

        Pause
    
    }

    #Start Porgram

    FirstMenu #Call Menu

    $NewOpt = read-host "`n`nPlease Select and option 1 or 2"
    switch ($NewOpt) {
        1 { NewStudent }
        2 { NewEmployee }
    }
Do{
$DoNew = read-host "And another User? (Y or N)"
if ($DoNew -in $ValAns){
    if ($DoNew -in ("Y","y")){
        $AnsCheck = $true
    }
    else{
        $AnsCheck = $false
        Write-host "End Program"
        Pause
        Clear-Host
    }
}
Else{
    Write-Host
}
} while ($AnsCheck -eq $false)

} while ($NewU)

