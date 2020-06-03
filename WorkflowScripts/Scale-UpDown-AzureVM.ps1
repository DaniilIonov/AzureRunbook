workflow Scale-UpDown-AzureVM {
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$SubscriptionId,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$ResourceGroupName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$AzureVMList,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$VMSize
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
		$VMSizeList = Get-AzVMSize -ResourceGroupName $ResourceGroupName -VMName $AzureVM
		$VM = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $AzureVM

		if ($VMSizeList.Name -contains $VMSize -and $Null -ne $VM) {
			"VM named $AzureVM is scaling to size $VMSize" | Write-Output

			InlineScript {
				$VM = Get-AzVM -ResourceGroupName $Using:resourceGroupName -VMName $Using:azureVM
				$VM.HardwareProfile.VMSize = $Using:VMSize
				Update-AzVM -VM $VM -ResourceGroupName $Using:resourceGroupName
			}

			"VM sizing task is complete." | Write-Output
		}
		else {
			"VM Size $VMSize is not available. Please retry." | Write-Error
		}
	}

	"End of script!" | Write-Output
}