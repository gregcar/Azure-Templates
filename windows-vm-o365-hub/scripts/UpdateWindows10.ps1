Process {
  Install-Module PSWindowsUpdate
  Get-Command –module PSWindowsUpdate
  Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
  Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot
}

# { "name": "UpdateWindows", "type": "extensions", "location": "[resourceGroup().location]", "apiVersion": "2017-03-30", "dependsOn": [ "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"],
# "tags": { "displayName": "UpdateWindows" },
# "properties": { "publisher": "Microsoft.Compute", "type": "CustomScriptExtension", "typeHandlerVersion": "1.8", "autoUpgradeMinorVersion": true, 
# "settings": { "fileUris": ["[concat(parameters('_artifactsLocation'), parameters('updateWindowsScriptFileName'))]"], "commandToExecute": "[concat('powershell -ExecutionPolicy bypass -File ', parameters('updateWindowsScriptFileName'))]" }}},