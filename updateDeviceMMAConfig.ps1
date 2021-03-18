param(
	[parameter(HelpMessage= "Input CSV file location")]
	[string]$InputCsvPath,

	[parameter(Position=0, HelpMessage= "List of comma separated computer names")]
	[string[]]$ComputerNames,

	[parameter(Mandatory, HelpMessage= "Provide 'add' or 'remove' for -ActionType")]
	[ValidateSet("add","remove")]
	[string]$ActionType,

	[parameter(Mandatory, HelpMessage= "Azure Log Analytics Workspace ID")]
	[string]$WorkspaceId,

	[parameter(HelpMessage= "Azure Log Analytics Workspace Key")]
	[string]$WorkspaceKey
)

if ($InputCsvPath -and $ComputerNames) {
	Write-Host -ForegroundColor red -BackgroundColor black "Error! Select either -InputCsvPath or -ComputerNames. You cannot use both."
	Write-Host "Exiting..."
	exit 1
} elseif ($ActionType -eq "add" -and !$WorkspaceKey) {
	Write-Host -ForegroundColor red -BackgroundColor black "Error! Workspace key needs to be provided when performing an 'add' action."
	Write-Host "Exiting..."
	exit 1
} elseif ($InputCsvPath) {
	try {
		$csv = Import-Csv -Path $InputCsvPath
		try {
			$devices = $csv | Select-Object -ExpandProperty ComputerName
		}
		catch {
			Write-Host -ForegroundColor red -BackgroundColor black "Error! Could not retrieve values from the column 'ComputerName'."
			Write-Host "Exiting..."
			exit 1
		}
	}
	catch {
		Write-Host -ForegroundColor red -BackgroundColor black "Error! Could not open CSV file '$InputCsvPath'. Please check and try again."
		Write-Host "Exiting..."
		exit 1
	}
} elseif ($ComputerNames) {
	$devices = $ComputerNames
} else {
	Write-Host -ForegroundColor red -BackgroundColor black "Error! Either -ComputerNames or -InputCsvPath must be specified. Please check and try again."
	Write-Host "Exiting..."
	exit 1
}

Do {
	$response = Read-Host "`nYou are about to deploy changes to $($devices.count) devices - are you sure? [y/n]"
	if ($response.ToLower() -eq "n") { exit 1}
	elseif ($response.ToLower() -eq "y") { break }
	else { Write-Host -ForegroundColor red -BackgroundColor black "Error! Invalid response - please select 'y' or 'n'!" } 
}
while ($true)

Write-Host "`n"
Foreach ($device in $devices) {
	Write-Host -NoNewLine "Connecting to device $device and updating monitoring agent...";
	try {
		$so = New-PSSessionOption -OpenTimeout 3
		$scriptBlockErr = Invoke-Command -SessionOption $so -ComputerName $device -ErrorAction Stop -ScriptBlock {
			try {
				$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' 
				if ( $using:ActionType -eq "add") {
					$mma.AddCloudWorkspace($using:WorkspaceId, $using:WorkspaceKey) 
				} elseif ($using:ActionType -eq "remove") {
					$mma.RemoveCloudWorkspace($using:WorkspaceId) 
				} else {
					Throw 
				}
				$mma.ReloadConfiguration()
			}
			catch {
				$true
			}
		}
		if ($scriptBlockErr) {
			Write-Host -ForegroundColor red -BackgroundColor black "Error! There was a problem running the scriptblock on $device!"
		} else {
			"Success!"
		}
	}
	catch  {
		$errType = $_.Exception.GetType().FullName
		Write-Host -ForegroundColor red -BackgroundColor black "Error!`nCould not connect with Invoke-Command: $errType"
	}
}
