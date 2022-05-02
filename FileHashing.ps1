$Hashes = ("MD5","SHA1","SHA256", "SHA384", "SHA512")
$FileAndPath = read-host "Enter Path and File with extendion:"

foreach($Hashes in $Hashes){
    Get-FileHash -Path $FileAndPath -Algorithm $Hashes
}
