function Get-FileToHash {
    $FileToHash = read-host "Enter path and filename of file to test Hash(s)"
    if (Test-Path $FileToHash) {
        return $FileToHash
    }
    else {
        Get-FileToHash
    }
}

function Get-ControlHash {
    $ControlHash = read-host "Enter known hash"
    if ($ControlHash -match ".*[A-Za-z\d]$") {
        return $ControlHash
    }
    else {
        Get-ControlHash
    }
}
$FileTohash = Get-FileToHash
$ControlHash = Get-ControlHash
$Algs = ("MD5", "SHA1", "SHA256", "SHA384", "SHA512")
write-host "Hash`t`tPath and File" -ForegroundColor Yellow
foreach ($Alg in $Algs) {
    $Hash = (Get-FileHash -Path $FileToHash -Algorithm $Alg).Hash
    Write-Host "[-]"$Alg "`t[:]" $FileToHash "`t[:]" $Hash | Format-Table
    if ($Hash -eq $ControlHash) {
        Write-Host "[+] Matches"$alg "Hash of" $FileTohash "[:]"$ControlHash -ForegroundColor Green
    }
}
