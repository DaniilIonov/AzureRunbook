workflow Scale-UpDown-AzureVM {
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
		$VmSize
	)

	$ErrorActionPreference = "Stop"
	$WarningPreference = "Continue"
	$VerbosePreference = "Continue"

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

	foreach ($AzureVM in $AzureVMsToHandle) {
		$VmSizeList = Get-AzVMSize -ResourceGroupName $ResourceGroupName -VMName $AzureVM
		$Vm = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $AzureVM

		if ($VmSizeList.Name -contains $VmSize -and $Null -ne $Vm) {
			"VM named $AzureVM is scaling to size $VmSize" | Write-Output

			InlineScript {
				$Vm = Get-AzVM -ResourceGroupName $Using:resourceGroupName -VMName $Using:azureVM
				$Vm.HardwareProfile.VmSize = $Using:vmSize
				Update-AzVM -VM $Vm -ResourceGroupName $Using:resourceGroupName
			}

			"VM sizing task is complete." | Write-Output
		} 
		else {
			"VM Size $VmSize is not available. Please retry." | Write-Error
		}
	}

	"End of script!" | Write-Output
}