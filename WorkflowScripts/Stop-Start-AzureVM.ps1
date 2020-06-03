workflow Stop-Start-AzureVM {
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $True)]
		[System.String]
		$SubscriptionId,

		[Parameter(Mandatory = $True)]
		[System.String]
		$ResourceGroupName,

		[Parameter(Mandatory = $True)]
		[System.String]
		$AzureVMList,

		[Parameter(Mandatory = $True)]
		[System.String]
		$Action
	)

	$ErrorActionPreference = "Stop"
	$WarningPreference = "Continue"
	$VerbosePreference = "Continue"

	$SupportedActions = "Start", "Stop"
	if ($SupportedActions -notContains $Action) {
		"Action not supported: $Action" | Write-Error
	}

	"Starting..." | Write-Output

	# Ensures you do not inherit an AzContext in your runbook
	$Autosave = Disable-AzContextAutosave –Scope Process

	$Connection = Get-AutomationConnection -Name AzureRunAsConnection
	$ConnectionResult = Connect-AzAccount -ServicePrincipal -Tenant $Connection.TenantID -ApplicationId $Connection.ApplicationID -CertificateThumbprint $Connection.CertificateThumbprint

	$Context = Set-AzContext -SubscriptionId $SubscriptionId

	if ($AzureVMList -notlike "All") {
		$AzureVMsToHandle = $AzureVMList.Split(",")
	}
	else {
		$AzureVMsToHandle = @(Get-AzVM -ResourceGroupName $ResourceGroupName).Name
	}
	"Azure VMs: $AzureVMsToHandle" | Write-Output

	foreach ($AzureVM in $AzureVMsToHandle) {
		if ($Null -eq $(Get-AzVM -Name $AzureVM)) {
			"AzureVM : [$AzureVM] - Does not exist! - Check your inputs" | Write-Error
		} 
	}

	if ($Action -like "Stop") {
		"Stopping VMs:" | Write-Output

		foreach ($AzureVM in $AzureVMsToHandle) {
			"Stopping the VM: $AzureVM" | Write-Output
			Get-AzVM -Name $AzureVM | Stop-AzVM -Force | Write-Output
		}
	} 
	else {
		"Starting VMs:" | Write-Output

		foreach ($AzureVM in $AzureVMsToHandle) {
			"Starting the VM: $AzureVM" | Write-Output
			Get-AzVM -Name $AzureVM | Start-AzVM | Write-Output
		}
	} 

	"End of script!" | Write-Output
}