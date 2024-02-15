function Get-FileToHash {
    $FileToHash = read-host "Enter path and filename of file to test eg 'c:\???\?????\?????.???'"
    if (Test-Path $FileToHash) {
        return $FileToHash
    }
    else {
        Get-FileToHash
    }
}

function Get-ControlHash {
    $ControlHash = read-host "Enter known checksum"
    if ($ControlHash -match ".*[A-Za-z\d]$") {
        return $ControlHash
    }
    else {
        Get-ControlHash
    }
}

$FileTohash = Get-FileToHash
$ControlHash = Get-ControlHash
$Algs = ("MD5","SHA1", "SHA256", "SHA384", "SHA512")
write-host "Algorithm`t`tFile Hash" -ForegroundColor Yellow
foreach ($Alg in $Algs) {
    $Hash = (Get-FileHash -Path $FileToHash -Algorithm $Alg).Hash
    [String]::Format("[-] {0}`t`t{1}", $Alg, $Hash) 
    if ($Hash -eq $ControlHash) {
        write-host "[+] Matches "$Alg"`t"$Hash -ForegroundColor Green
        $Match = $true
        break
    }
}
if($Match -ne $true){
    write-host "[::] File did not match given file hash in any hash Algorythm!!!"-ForegroundColor Red
}
