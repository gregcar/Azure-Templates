# Create a SharePoint Farm with 4 VMs using the Powershell DSC Extension

This template will create a SharePoint 2016 non-HA farm using the PowerShell DSC Extension it creates the following resources:

+	A Virtual Network
+	Three Storage Accounts one is used for AD VMs, one for SQL Server VMs and one for SP VMs
+	Three external and one internal load balancers
+	A NAT Rule to allow RDP to one VM which can be used as a jumpbox, a load balancer rule for ILB for a SQL Listener, a load balancer rule for HTTP traffic on port 80 for SharePoint and a NAT rule for Sharepoint Central Admin access
+ 	Three public IP addresses, one for RDP access, one for the SharePoint site and one for SharePoint Central Admin.
+	One VM as Domain Controller for a new Forest and Domain
+	One running SQL Server 2014 with an availability group
+	One SharePoint App Server
+	One SharePoint Web Server
+	Four Availability Sets one for the AD VM, one for the SQL, one for the SharePoint App Servers and one for the SharePoint Web Servers.

## Notes

+	The default settings for storage are to deploy using **premium storage**, the AD witness and SP VMs use a P10 Disk and the SQL VMs use two P30 disks each, these sizes can be changed by changing the relevant variables. In addition there is a P10 Disk used for each VMs OS Disk.

+ 	In default settings for compute require that you have at least 19 cores of free quota to deploy.

+	Public Endpoints are created for the SharePoint site that this template creates and for the Central Admin site, however no permissions are given to any user for the new SharePoint site created, these will need to be added from the Central Admin site.

+ 	The images used to create this deployment are
	+ 	AD - Latest Windows Server 2012 R2 Image
	+ 	SQL Server - Latest SQL Server 2014 on Windows Server 2012 R2 Image
	+ 	Witness - Latest Windows Server 2012 R2 Image
	+	SharePoint - Latest SharePoint server 2013 trial image on Windows Server 2012 R2

+ 	The image configuration is defined in variables - details below - but the scripts that configure this deployment have only been tested with these versions and may not work on other images.

+ 	Once deployed access can be gained at the following addresses:

	+	**SharePoint Website** - http://parameter(dnsPrefix).parameter(location).cloudapp.azure.com
	+	**Central Admin Website** - http://parameter(spCentralAdminDNSPrefix).parameter(location).cloudapp.azure.com
	+	**RDP Jump Box** - mstsc -v parameter(rdpDNSPrefix).parameter(location).cloudapp.azure.com

+ 	For this sample DSC packages need to be staged from 'dscv2' directory.


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgregcar%2FAzure-Templates%2Fmaster%2Fsharepoint-server-farm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Notable Variables

|Name|Description|
|:---|:---------------------|
|virtualNetworkName|Name of the Virtual Network|
|adPDCVMName|The name of the Primary Domain Controller|
|sqlVMName|The prefix for the SQL VM Name|
|spwebVMName|The Prefix of the SharePoint Web Server VM|
|spappVMName|The Prefix of the SharePoint App Server VM|
|windowsImagePublisher|The name of the pulisher of the AD Image|
|windowsImageOffer|The Offer Name for the Image used by AD VM|
|windowsImageSKU|The Image SKU for the AD Image|
|sqlImagePublisher|The name of the pulisher of the SQL Image|
|sqlImageOffer|The Offer Name for the Image used by SQL|
|sqlImageSKU|The Image SKU for the SQL Image|
|spImagePublisher|The name of the pulisher of the SharePoint Image|
|spImageOffer|The Offer Name for the Image used by SharePoint|
|spImageSKU|The Image SKU for the SharePoint Image|
|windowsDiskSize|The size of the VHD allocated for AD VM Data Disk|
|sqlDiskSize|The size of the the VHD allocated for SQL VM Data and Log Disks|
|spDiskSize|The size of the VHD allocated for the SP VMs Data Disk|
