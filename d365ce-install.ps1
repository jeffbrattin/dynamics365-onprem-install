# d365ce-install.ps1
# Installs Dynamics 365 Customer Engagement (on-premises) Customer Service module, SQL Server components, and prerequisites

# Variables
$installDir = "C:\Install"
$d365SetupPath = "$installDir\Dynamics365Server"
$sqlServer = "localhost"
$orgName = "WorthyBrands"
$baseLanguage = "1033" # English
$setupFile = "$d365SetupPath\SetupServer.exe"
$downloadUrl = "https://download.microsoft.com/download/<path-to-d365-installer>" # Replace with actual Dynamics 365 installer URL
$sqlNativeClientUrl = "https://download.microsoft.com/download/<path-to-sqlncli>" # Replace with actual SQL Native Client URL
$sqlClrTypesUrl = "https://download.microsoft.com/download/<path-to-sqlclrtypes>" # Replace with actual SQL CLR Types URL
$sqlSharedMgmtUrl = "https://download.microsoft.com/download/<path-to-sharedmgmt>" # Replace with actual Shared Management Objects URL

# Create installation directory
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# Download Dynamics 365 installer
Invoke-WebRequest -Uri $downloadUrl -OutFile "$installDir\Dynamics365Server.zip"
Expand-Archive -Path "$installDir\Dynamics365Server.zip" -DestinationPath $d365SetupPath -Force

# Install Prerequisites
# Install .NET Framework 4.8 (required for Dynamics 365)
Start-Process -FilePath "powershell" -ArgumentList "-Command Install-WindowsFeature -Name NET-Framework-45-Features" -Wait

# Install IIS with required features
Install-WindowsFeature -Name Web-Server, Web-WebServer, Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-App-Dev, Web-Asp-Net45, Web-Net-Ext45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Security, Web-Filtering, Web-Performance, Web-Stat-Compression, Web-Mgmt-Console -IncludeManagementTools

# Download and install SQL Server prerequisites
Invoke-WebRequest -Uri $sqlNativeClientUrl -OutFile "$installDir\sqlncli_x64.msi"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installDir\sqlncli_x64.msi /quiet /norestart" -Wait
Invoke-WebRequest -Uri $sqlClrTypesUrl -OutFile "$installDir\SQLSysClrTypes_x64.msi"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installDir\SQLSysClrTypes_x64.msi /quiet /norestart" -Wait
Invoke-WebRequest -Uri $sqlSharedMgmtUrl -OutFile "$installDir\SharedManagementObjects_x64.msi"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $installDir\SharedManagementObjects_x64.msi /quiet /norestart" -Wait

# Install Dynamics 365 Server (Customer Service module)
Start-Process -FilePath $setupFile -ArgumentList "/install /quiet /config:$installDir\config.xml" -Wait

# Configuration XML for Dynamics 365 Setup
$configXml = @"
<Deployments>
  <Deployment>
    <ServerRoles>
      <Role Name="FullServer" />
    </ServerRoles>
    <DatabaseServer>$sqlServer</DatabaseServer>
    <Organization>
      <Name>$orgName</Name>
      <DisplayName>Contoso Inc.</DisplayName>
      <BaseCurrencyCode>USD</BaseCurrencyCode>
      <BaseLanguageCode>$baseLanguage</BaseLanguageCode>
    </Organization>
    <ReportingServerUrl>http://$sqlServer/ReportServer</ReportingServerUrl>
    <InstallDir>C:\Program Files\Microsoft Dynamics CRM</InstallDir>
  </Deployment>
</Deployments>
"@
$configXml | Out-File -FilePath "$installDir\config.xml" -Encoding UTF8

# Install Dynamics 365 Reporting Extensions
