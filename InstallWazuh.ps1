
Write-Host "---  Getting computer information on current system  ---" -ForegroundColor Black -BackgroundColor White

$CompName = (Get-ComputerInfo).CsName

Write-Host "---  Installing Wazuh agent on this computer:"$CompName "  ---"

Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.1-1.msi `
-OutFile ${env.tmp}\wazuh-agent; msiexec.exe /i ${env.tmp}\wazuh-agent /q WAZUH_MANAGER='192.168.0.32' `
WAZUH_AGENT_GROUP='laptop,default' WAZUH_AGENT_NAME=$CompName WAZUH_REGISTRATION_SERVER='192.168.0.32' 

write-host "Wazuh installed on "$CompName

try {
    Start-Service WazuhSvc
    if ((Get-Service WazuhSvc).status -eq 'Running'){
        Write-Host "Wazuh Service is now running on "$CompName
    }
}
catch {
    <#Do this if a terminating exception happens#>
    Start-Service Wazuh
}

