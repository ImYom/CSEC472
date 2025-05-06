# RIT CSEC472 - Group 20
# Purpose: Update a user's role based on a job title

param(
    [Parameter(Mandatory=$true)]
    [string]$SamAccountName,

    [Parameter(Mandatory=$true)]
    [string]$JobTitle,

    [Parameter(Mandatory=$false)]
    [string]$MappingCsvPath = "C:\Users\Administrator\Documents\RBAC Data\RBAC_Mapping.csv"
)

# Load job title mappings
$mapping = Import-Csv -Path $MappingCsvPath | Where-Object { $_.'Job Title' -eq $JobTitle }

if (-not $mapping) {
    Write-Error "❌ Job title '$JobTitle' not found in mapping CSV."
    exit 1
}

# Lookup user
$user = Get-ADUser -Identity $SamAccountName -Properties Title, Department, employeeID, employeeNumber, info

if (-not $user) {
    Write-Error "❌ User '$SamAccountName' not found in Active Directory."
    exit 1
}

# Update AD attributes based on role mapping
Set-ADUser -Identity $SamAccountName -Replace @{
    Title          = $mapping.'Job Title'
    Department     = $mapping.'Department Name'
    employeeID     = $mapping.'Role Code'
    employeeNumber = $mapping.'Dept Code'
    info           = $mapping.'Dept-Team Code'
}

Write-Host "✅ Updated user '$SamAccountName' with job title '$JobTitle'"
