# RIT CSEC472 - Group 20
# Purpose: Adds and removes users to the correct security group based on a role code.

# Security group and role mappings
$roleToGroupMap = @{
    "ROLE_BRANCHMGR"     = "SG_BranchManager"
    "ROLE_VPFIN"         = "SG_VP_Finance"
    "ROLE_DIRACCT"       = "SG_Accounting"
    "ROLE_ACCT"          = "SG_Accounting"
    "ROLE_DIRTREAS"      = "SG_Treasury"
    "ROLE_TREASSPEC"     = "SG_Treasury"
    "ROLE_VPOPS"         = "SG_VP_Operations"
    "ROLE_DIRTELLER"     = "SG_TellerServices"
    "ROLE_TELLER"        = "SG_TellerServices"
    "ROLE_DIRLENDING"    = "SG_CommercialLending"
    "ROLE_LOANOFFICER"   = "SG_CommercialLending"
    "ROLE_MORTGAGESPEC"  = "SG_CommercialLending"
    "ROLE_DIRRETAIL"     = "SG_RetailBanking"
    "ROLE_PBANKER"       = "SG_RetailBanking"
    "ROLE_VPIT"          = "SG_VP_IT"
    "ROLE_DIRIT"         = "SG_ITSupport"
    "ROLE_ITSUPPORT"     = "SG_ITSupport"
    "ROLE_DIRSEC"        = "SG_Cybersecurity"
    "ROLE_SECANALYST"    = "SG_Cybersecurity"
}

# Define all RBAC-related groups
$rbacGroups = $roleToGroupMap.Values | Select-Object -Unique

# Logging paths
$ChangedLog = "C:\Users\Administrator\Documents\RBAC Logs\GroupSync_Changes.csv"
$SkippedLog = "C:\Users\Administrator\Documents\RBAC Logs\GroupSync_Skipped.csv"
Remove-Item -Path $ChangedLog, $SkippedLog -ErrorAction SilentlyContinue

# Get all users in the employee OU
$users = Get-ADUser -SearchBase "OU=Employees,DC=silvergate,DC=com" -Filter * -Properties employeeID, memberOf, SamAccountName

foreach ($user in $users) {
    $role = $user.employeeID
    $currentGroups = ($user.memberOf | Get-ADGroup).Name
    $expectedGroup = $roleToGroupMap[$role]

    if (-not $expectedGroup) {
        Add-Content -Path $SkippedLog -Value "$($user.SamAccountName),No role match"
        continue
    }

    $changesMade = $false

    # Remove user from incorrect RBAC groups
    foreach ($group in $rbacGroups) {
        if ($group -ne $expectedGroup -and $currentGroups -contains $group) {
            Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
            Write-Host "Removed $($user.SamAccountName) from $group"
            $changesMade = $true
        }
    }

    # Add user to correct group if not already a member
    if ($currentGroups -notcontains $expectedGroup) {
        Add-ADGroupMember -Identity $expectedGroup -Members $user
        Write-Host "Added $($user.SamAccountName) to $expectedGroup"
        $changesMade = $true
    }

    # log changes
    if ($changesMade) {
        Add-Content -Path $ChangedLog -Value "$($user.SamAccountName),$role,$expectedGroup"
    } else {
        Add-Content -Path $SkippedLog -Value "$($user.SamAccountName),Already correct"
    }
}
