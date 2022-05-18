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
$FileTohash = read-host "Enter path and file name. eg: 'c:\####\####\#######.iso'"  # Get-FileToHash
$ControlHash = read-host "Enter given hash checksum to verify" # Get-ControlHash
$Algs = ("SHA1", "SHA256", "SHA384", "SHA512")
write-host "Hash`t`t`tFile Hash" -ForegroundColor Yellow
foreach ($Alg in $Algs) {
    $Hash = (Get-FileHash -Path $FileToHash -Algorithm $Alg).Hash
    [String]::Format("[-] {0}`t`t{1}", $Alg, $Hash) 
    if ($Hash -eq $ControlHash) {
        write-host "[+] Matches "$Alg"`t"$Hash -ForegroundColor Green
        $Match = $true
    }
}
if($Match -ne $true){
    write-host "[::] File did not match given file hash in any hash Algorythm!!!"-ForegroundColor Red
}
