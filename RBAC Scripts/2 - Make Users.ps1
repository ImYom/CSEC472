# RIT CSEC472 - Group 20
# Purpose: Creates new users in an AD Domain from a CSV

$csvPath = "C:\Users\Administrator\Documents\RBAC Data\Users.csv"

# Import users from CSV
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    try {
        $name = "$($user.'First Name') $($user.'Last Name')"
        $initialPassword = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force

        # Create the AD user
        New-ADUser `
            -Name $name `
            -GivenName $user.'First Name' `
            -Surname $user.'Last Name' `
            -SamAccountName $user.sAMAccountName `
            -UserPrincipalName $user.userPrincipalName `
            -Title $user.title `
            -Department $user.department `
            -Company $user.company `
            -Path "OU=Employees,DC=silvergate,DC=com" `
            -AccountPassword $initialPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true
        Set-ADUser -Identity $user.sAMAccountName -Replace  @{
                employeeID = $user.extensionAttribute1
                employeeNumber = $user.extensionAttribute2
                info = $user.extensionAttribute3
            }

        Write-Host "✅ Created user: $name"

    } catch {
        Write-Warning "❌ Failed to create user: $($user.sAMAccountName) - $($_.Exception.Message)"
    }
}




