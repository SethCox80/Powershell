
# Import CSV (headers: Username)
$rows = Import-Csv ".\Student_MS_Info_24-46.csv"

# Prepare results array
$results = @()


foreach ($row in $rows) {

    $upn = $row.Username
    $FirstName = $row.First_Name
    $LastName = $row.Last_Name
    #$Username = $row.Username
    #$DisplayName = "$FirstName $LastName"
    $Department = $row.Grade
    #$Title = "Student"
    #$Password = $row.Password
    try {
        if (Get-MgUser -Filter "userPrincipalName eq '$upn'") {
            Write-Output "$upn - Exists"
            $results += [pscustomobject]@{
                Username  = $upn
                FirstName = $FirstName
                LastName  = $LastName
                Grade     = $Department
                Status    = "Exists"
            }
            
        }
        else {
            Write-Output "$upn $FirstName $LastName $Department - Not Found"
            $results += [pscustomobject]@{
                Username  = $upn
                FirstName = $FirstName
                LastName  = $LastName
                Grade     = $Department
                Status    = "Not Found"
            }
            
        }
    }
    catch {
        Write-Output "$upn - Error"
        $results += [pscustomobject]@{
            Username  = $upn
            FirstName = $FirstName
            LastName  = $LastName
            Grade     = $Department
            Status    = "Error"
        }
    }
}

# Export results to CSV
$results | Export-Csv ".\UserAnalysis.csv" -NoTypeInformation -Encoding UTF8
