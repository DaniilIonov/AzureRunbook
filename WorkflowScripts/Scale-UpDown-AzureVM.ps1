workflow Scale-UpDown-AzureVM {
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $true)]
		[String]
		$subscriptionId,

		[Parameter(Mandatory = $true)]
		[String]
		$resourceGroupName,

		[Parameter(Mandatory = $true)]
		[String]
		$azureVMList,

		[Parameter(Mandatory = $true)]
		[String]
		$vmSize
	)

	$ErrorActionPreference = "Stop"
	$WarningPreference = "Continue"
	$VerbosePreference = "Continue"

	"Starting..." | Write-Output

	# Ensures you do not inherit an AzContext in your runbook
	$autosave = Disable-AzContextAutosave –Scope Process

	$connection = Get-AutomationConnection -Name AzureRunAsConnection
	$connectionResult = Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

	$context = Set-AzContext -SubscriptionId $subscriptionId

    if ($azureVMList -notlike "All") {
        $azureVMsToHandle = $azureVMList.Split(",")
    }
    else {
        $azureVMsToHandle = @(Get-AzVM -ResourceGroupName $resourceGroupName).Name
    }
    "Azure VMs: $azureVMsToHandle" | Write-Output

    foreach ($azureVM in $azureVMsToHandle) {
        if ($null -eq $(Get-AzVM -Name $azureVM)) {
            "AzureVM : [$azureVM] - Does not exist! - Check your inputs" | Write-Error
		}
	}

	foreach ($azureVM in $azureVMsToHandle) {
		$vmSizeList = Get-AzVMSize -ResourceGroupName $resourceGroupName -VMName $azureVM
		$vm = Get-AzVM -ResourceGroupName $resourceGroupName -VMName $azureVM

		if ($vmSizeList.Name -contains $vmSize -and $null -ne $vm) {
			"VM named $azureVM is scaling to size $vmSize" | Write-Output

			InlineScript {
				$vm = Get-AzVM -ResourceGroupName $using:resourceGroupName -VMName $using:azureVM
				$vm.HardwareProfile.VmSize = $using:vmSize
				Update-AzVM -VM $vm -ResourceGroupName $using:resourceGroupName
			}

			"VM sizing task is complete." | Write-Output
		} 
		else {
			"VM Size $vmSize is not available. Please retry." | Write-Error
		}
	}

	"End of script!" | Write-Output
}