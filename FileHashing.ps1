$Algs = ("MD5","SHA1","SHA256", "SHA384", "SHA512")
$FileToTest = "C:\Temp\ubuntu-20.04.4-live-server-amd64.iso"

$ControlHash = read-host "Enter known hash"

write-host "Hash`t`tPath and File" -ForegroundColor Yellow
foreach($Alg in $Algs){
    $Hash = (Get-FileHash -Path $FileToTest -Algorithm $Alg).Hash
    Write-Host "[-]"$Alg "`t[:]" $FileToTest "`t[:]" $Hash | Format-Table
    if($Hash -eq $ControlHash){
        Write-Host "[+] Matches"$alg "Hash of" $FileToTest "[:]"$ControlHash -ForegroundColor Green
    }
 }
 