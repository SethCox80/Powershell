Clear-Host
Write-Host "Finding Azure Active Directory Accounts..."
$Users = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq $True}
$Report = [System.Collections.Generic.List[Object]]::new() # Create output file
Write-Host "Processing" $Users.Count "accounts..." 
ForEach ($User in $Users) {
   #$MFAMethods = $User.StrongAuthenticationMethods.MethodType
   $MFAEnforced = $User.StrongAuthenticationRequirements.State
   $DefaultMFAMethod = ($User.StrongAuthenticationMethods | Where-Object {$_.IsDefault -eq "True"}).MethodType
   If (($MFAEnforced -eq "Enforced") -or ($MFAEnforced -eq "Enabled")) {
      Switch ($DefaultMFAMethod) {
        "OneWaySMS"             { $MethodUsed = "One-way SMS" }
        "TwoWayVoiceMobile"     { $MethodUsed = "Phone call verification" }
        "PhoneAppOTP"           { $MethodUsed = "Hardware token or authenticator app" }
        "PhoneAppNotification"  { $MethodUsed = "Authenticator app" }
      } #End Switch
    }
    Else {
          $MFAEnforced= "Not Enabled"
          $MethodUsed = "MFA Not Used" }
  
   $ReportLine = [PSCustomObject] @{
           User        = $User.UserPrincipalName
           Name        = $User.DisplayName
           MFAUsed     = $MFAEnforced
           MFAMethod   = $MethodUsed }
                 
    $Report.Add($ReportLine) 
} # End For

Write-Host "Report is in c:\temp\MFAUsers.CSV"
$Report | Select-Object Name, MFAUsed, MFAMethod | Out-GridView
$Report | Export-CSV -NoTypeInformation c:\temp\MFAUsers.CSV