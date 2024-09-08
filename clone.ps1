$url = "https://github.com/SethCox80/SetupGuides.git"
$output = "C:\Temp\main.zip"
$start_time = Get-Date

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"