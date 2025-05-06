# RIT CSEC472 - Group 20
# Purpose: Creates new security groups in an AD Domain from a CSV

$groups = @(
    @{ Name = "SG_BranchManager";         Description = "Branch Manager Access Group" },
    @{ Name = "SG_VP_Finance";            Description = "VP of Finance Access Group" },
    @{ Name = "SG_Accounting";            Description = "Accounting Department Access Group" },
    @{ Name = "SG_Treasury";              Description = "Treasury Department Access Group" },
    @{ Name = "SG_VP_Operations";         Description = "VP of Operations Access Group" },
    @{ Name = "SG_TellerServices";        Description = "Teller Services Team Access Group" },
    @{ Name = "SG_CommercialLending";     Description = "Commercial Lending Team Access Group" },
    @{ Name = "SG_RetailBanking";         Description = "Retail Banking Team Access Group" },
    @{ Name = "SG_VP_IT";                 Description = "VP of Information Technology Access Group" },
    @{ Name = "SG_ITSupport";             Description = "IT Support Team Access Group" },
    @{ Name = "SG_Cybersecurity";         Description = "Cybersecurity Team Access Group" }
)

# Set where to create the groups in AD
$ou = "OU=Groups,DC=silvergate,DC=com"

foreach ($group in $groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$($group.Name)'" -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $group.Name `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $ou `
            -Description $group.Description

        Write-Host "✅ Created group: $($group.Name)"
    }
    else {
        Write-Host "⚠️ Group already exists: $($group.Name)"
    }
}
