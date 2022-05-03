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
$FileTohash = "C:\Temp\ubuntu-20.04.4-live-server-amd64.iso"  # Get-FileToHash
$ControlHash =  "28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad" # Get-ControlHash
$Algs = ("MD5", "SHA1", "SHA256", "SHA384", "SHA512")
write-host "Hash`t`tPath and File" -ForegroundColor Yellow
foreach ($Alg in $Algs) {
    $Hash = (Get-FileHash -Path $FileToHash -Algorithm $Alg).Hash
    [String]::Format("[-] {0} `t`t {1} `t {2}", $Alg, $FileToHash, $Hash) 
    if ($Hash -eq $ControlHash) {
        [String]::Format("[+] Matches {0} Hash of {1} [:] {2}", $Alg, $FileToHash, $Hash)
        $Match = $true
    }
}
if($Match -ne $true){
    write-host "File did not match known hash in any hash Algorythm!!!"-ForegroundColor Red
}
