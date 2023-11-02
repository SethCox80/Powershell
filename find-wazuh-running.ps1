$services = Get-Service -ErrorAction SilentlyContinue | Select-Object *
$result = ""

foreach ($service in $services){
    # Write-Host $service
    if ($service.Name -eq 'WazuhSvc'){
        write-host "Wazuh found" -ForegroundColor Green
        Write-Host "||Name:"$service.Name, "||Startup type:"$service.StartupType, "||Status:"$service.Status -ForegroundColor Yellow
        $service | Out-File -FilePath C:\Temp\WazuhResult.txt
        if ($service.Status -ne "Running"){
            write-host "Service Stopped" -ForegroundColor Red
        }
        $found = $true
    }
}
if($found -ne $true){
    write-host "Wazuh not installed" -ForegroundColor Red
}
