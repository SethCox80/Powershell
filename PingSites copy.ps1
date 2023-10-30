$names = Get-content "C:\Git\Powershell\block.txt"
$r = @{}

foreach ($name in $names){
  Write-Host ("Checking: ",$name," ") -foregroundcolor yellow -NoNewline
  $r = Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue
  Write-Host ($r.Destination, $r.Address.IPAddressToString, " ") -NoNewline
  if ($r.Address -eq '10.10.10.1'){
    Write-Host "Blocked with pfblocker" -ForegroundColor Red
  }
  Elseif ($r.Address -ne '10.10.10.1'){
    write-host -NoNewline $r.Address.IPAddressToString "Not on List" `n

  }
  Else{
    write-host -NoNewline "Not on List" `n
  }
}