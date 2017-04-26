param([Parameter(Mandatory=$false)][string]$OfficeVersion = "Office2016")

configureRemoteSettings
installOffice
updateWindows

function configureRemoteSettings{
  # Enable Remote Desktop
  Write-Host
  Write-Host "`t Configuring remote desktop settings. Please wait ..." -ForeGroundColor "Yellow"
  (Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
  (Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
  Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true
  NET LOCALGROUP "Remote Desktop Users" "Authenticated Users" /add
}

function installOffice{
#  Office ProPlus Click-To-Run Deployment Script example
#
#  This script demonstrates how utilize the scripts in OfficeDev/Office-IT-Pro-Deployment-Scripts repository together to create
#  Office ProPlus Click-To-Run deployment script that will be adaptive to the configuration of the computer it is run from
  Write-Host
  Write-Host "`t Initialising Office install. Please wait ..." -ForeGroundColor "Yellow"

   $scriptPath = "."

  if ($PSScriptRoot) {
    $scriptPath = $PSScriptRoot
  } else {
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
  }

  #Importing all required functions
  . $scriptPath\Generate-ODTConfigurationXML.ps1
  . $scriptPath\Edit-OfficeConfigurationFile.ps1
  . $scriptPath\Install-OfficeClickToRun.ps1

  $targetFilePath = "$env:temp\configuration.xml"

  #This example will create an Office Deployment Tool (ODT) configuration file and include all of the Languages currently in use on the computer
  #from which the script is run.  It will then remove the Version attribute from the XML to ensure the installation gets the latest version
  #when updating an existing install and then it will initiate a install

  #This script additionally sets the "AcceptEULA" to "True" and the display "Level" to "None" so the install is silent.

  Generate-ODTConfigurationXml -Languages AllInUseLanguages -TargetFilePath $targetFilePath | Set-ODTAdd -Version $NULL | Set-ODTDisplay -AcceptEULA $true -Level None | Install-OfficeClickToRun -OfficeVersion $OfficeVersion

  # Configuration.xml file for Click-to-Run for Office 365 products reference. https://technet.microsoft.com/en-us/library/JJ219426.aspx
}

function updateWindows{
  $Today = Get-Date

  $UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
  $Searcher = New-Object -ComObject Microsoft.Update.Searcher
  $Session = New-Object -ComObject Microsoft.Update.Session

  Write-Host
  Write-Host "`t Initialising and Checking for Applicable Updates. Please wait ..." -ForeGroundColor "Yellow"
  $Result = $Searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

  If ($Result.Updates.Count -EQ 0) {
    Write-Host "`t There are no applicable updates for this computer."
  }
  Else {
    $ReportFile = $Env:ComputerName + "_Report.txt"
    If (Test-Path $ReportFile) {
      Remove-Item $ReportFile
    }
    New-Item $ReportFile -Type File -Force -Value "Windows Update Report For Computer: $Env:ComputerName`r`n" | Out-Null
    Add-Content $ReportFile "Report Created On: $Today`r"
    Add-Content $ReportFile "==============================================================================`r`n"
    Write-Host "`t Preparing List of Applicable Updates For This Computer ..." -ForeGroundColor "Yellow"
    Add-Content $ReportFile "List of Applicable Updates For This Computer`r"
    Add-Content $ReportFile "------------------------------------------------`r"
    For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++) {
      $DisplayCount = $Counter + 1
          $Update = $Result.Updates.Item($Counter)
      $UpdateTitle = $Update.Title
      Add-Content $ReportFile "`t $DisplayCount -- $UpdateTitle"
    }
    $Counter = 0
    $DisplayCount = 0
    Add-Content $ReportFile "`r`n"
    Write-Host "`t Initialising Download of Applicable Updates ..." -ForegroundColor "Yellow"
    Add-Content $ReportFile "Initialising Download of Applicable Updates"
    Add-Content $ReportFile "------------------------------------------------`r"
    $Downloader = $Session.CreateUpdateDownloader()
    $UpdatesList = $Result.Updates
    For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++) {
      $UpdateCollection.Add($UpdatesList.Item($Counter)) | Out-Null
      $ShowThis = $UpdatesList.Item($Counter).Title
      $DisplayCount = $Counter + 1
      Add-Content $ReportFile "`t $DisplayCount -- Downloading Update $ShowThis `r"
      $Downloader.Updates = $UpdateCollection
      $Track = $Downloader.Download()
      If (($Track.HResult -EQ 0) -AND ($Track.ResultCode -EQ 2)) {
        Add-Content $ReportFile "`t Download Status: SUCCESS"
      }
      Else {
        Add-Content $ReportFile "`t Download Status: FAILED With Error -- $Error()"
        $Error.Clear()
        Add-content $ReportFile "`r"
      }	
    }
    $Counter = 0
    $DisplayCount = 0
    Write-Host "`t Starting Installation of Downloaded Updates ..." -ForegroundColor "Yellow"
    Add-Content $ReportFile "`r`n"
    Add-Content $ReportFile "Installation of Downloaded Updates"
    Add-Content $ReportFile "------------------------------------------------`r"
    $Installer = New-Object -ComObject Microsoft.Update.Installer
    For ($Counter = 0; $Counter -LT $UpdateCollection.Count; $Counter++) {
      $Track = $Null
      $DisplayCount = $Counter + 1
      $WriteThis = $UpdateCollection.Item($Counter).Title
      Add-Content $ReportFile "`t $DisplayCount -- Installing Update: $WriteThis"
      $Installer.Updates = $UpdateCollection
      Try {
        $Track = $Installer.Install()
        Add-Content $ReportFile "`t Update Installation Status: SUCCESS"
      }
      Catch {
        [System.Exception]
        Add-Content $ReportFile "`t Update Installation Status: FAILED With Error -- $Error()"
        $Error.Clear()
        Add-content $ReportFile "`r"
      }	
    }
  }
}