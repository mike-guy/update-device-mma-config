# update-device-mma-config
Short and dirty powershell script to add/remove Azure Log Analytic spaces to an already installed Microsoft Monitoring Agent

## Intro
This script is based off of the PowerShell commands documented in https://docs.microsoft.com/en-us/azure/azure-monitor/agents/agent-manage#adding-or-removing-a-workspace and just adds some basically functionality to achieve bulk changes from a central device with very basic error checking/handling. There are better ways of doing this with configuration management systems, but it may be handy in a pinch or for a small number of devices.

## Testing
This has been tested against a vanilla Windows Server 2019 machine joined to a domain. It should work on older versions of OS, however this has not been tested. Please ensure you carry out your own testing prior to any bulk use - I'm not responsible for any issues.

## Prerequisites
The script assumes that WinRM is enabled in the environment and that remote powershell commands via Invoke-Command are enabled. The domain user running the command will need administrative permissions on the target machines.

## Usage
This script has the following mandatory parameters:
* -ActionType - Must be set to "add" or "remove" depending what you are trying to do
* -InputCsvPath OR -ComputerNames - Either provide a CSV file with computer names or add interactively in the terminal. The CSV file (if used) should only contain a single column with "ComputerName" as the heading.
* -WorkspaceId - Workspace ID is always required, regardless if you are adding or removing the workspace

This script has the following optional parameters:
* -WorkspaceKey - Only required if adding a workspace

```
.\updateDeviceMMAConfig.ps1 -ActionType [add | remove] -WorkspaceId \<WORKSPACE-ID\> [-WorkspaceKey \<WORKSPACE-KEY\>] [-InputCsvPath \<PATH-TO-CSV\> | -ComputerNames \<COMMA-SEPARATED-NAMES\>]
```

## Examples

### Add a new workspace to servers without a CSV file
```
.\updateDeviceMMAConfig.ps1 -ActionType add -WorkspaceId \<WORKSPACE-ID\> -WorkspaceKey \<WORKSPACE-KEY\> -ComputerNames someserver, anotherserver, yetanotherserver
```  
### Remove a workspace from servers without a CSV file
```
.\updateDeviceMMAConfig.ps1 -ActionType remove -WorkspaceId \<WORKSPACE-ID\> -ComputerNames someserver, anotherserver, yetanotherserver
```  
### Add a new workspace to servers with a CSV file
```
.\updateDeviceMMAConfig.ps1 -ActionType add -WorkspaceId \<WORKSPACE-ID\> -WorkspaceKey \<WORKSPACE-KEY\> -InputCsvPath myserverlist.csv
```
### Remove a workspace from servers with a CSV file
```
.\updateDeviceMMAConfig.ps1 -ActionType remove -WorkspaceId \<WORKSPACE-ID\> -InputCsvPath myserverlist.csv
```
  
