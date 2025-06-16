# adds-install.ps1
# Install and configure Active Directory Domain Services

$domainName = "contoso.local"
$domainOU = "OU=DynamicsOU,DC=contoso,DC=local"
$adminUsername = $env:adminUsername
$adminPassword = $env:adminPassword | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)

# Install AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote to Domain Controller and create new forest
Install-ADDSForest -DomainName $domainName `
  -DomainNetbiosName ( ($domainName -split "\.")[0] ) `
  -SafeModeAdministratorPassword $adminPassword `
  -InstallDns `
  -CreateDnsDelegation:$false `
  -NoRebootOnCompletion:$true `
  -Force

# Create Organizational Unit
New-ADOrganizationalUnit -Name "DynamicsOU" -Path "DC=$($domainName.Replace('.',',DC='))" -ProtectedFromAccidentalDeletion:$false

Write-Output "AD DS installation and OU creation completed. Reboot required."
