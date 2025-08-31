# Connect to Graph with User.ReadWrite.All permissions
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Departments to match
$targetDepartments = @("1","2","3","K")

# Get all matching users
$users = Get-MgUser -All -Property Id,UserPrincipalName,Department | Where-Object {
    $targetDepartments -contains $_.Department
}

Write-Host "Found $($users.Count) users to disable."

foreach ($user in $users) {
    try {
        Update-MgUser -UserId $user.Id -AccountEnabled:$false
        Write-Host "Locked user:" $user.UserPrincipalName $user.Department$_ -ForegroundColor Yellow
    } catch {
        Write-Host "Error locking user:" $user.UserPrincipalName $user.Department$_ -ForegroundColor Red
    }
}
