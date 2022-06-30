

$Users  = get-msoluser | Select-object userprincipalname, objectid, title, department

# write-host $Users

foreach ($User in $Users){
    $Student = $User.userprincipalname
    $ObjID = $User.objectid
    if ($User.Department -eq 'eighth'){
        write-host $Student 'will be unlocked' -foregroundcolor Blue
        Set-MsolUser -ObjectID $ObjID -BlockCredential $false
        $IsLocked = (get-msoluser -userprincipalname $Student).blockcredential 
        if ($IsLocked -eq $false){
            write-host '++ '$Student 'is now unlocked' -foregroundcolor Green
        }
        else {
            write-host '--   '$Student 'is still locked' -foregroundcolor Red
        }
    }
}