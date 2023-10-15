$names = Get-content "C:\Git\Powershell\block.txt"

foreach ($name in $names){
  $Lookup = nslookup.exe $name 
  Write-Host $Lookup
}