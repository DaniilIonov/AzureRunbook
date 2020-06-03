workflow Scale-UpDown-AzureResourceGroup {
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
		$VMSize,


		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$ServerName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$ElasticPoolName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Int32]
		$Dtu,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Int32]
		$DatabaseDtuMax,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Int32]
		$DatabaseDtuMin,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Int32]
		$StorageMB,


		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$AccountName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$DatabaseName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$ContainerName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Int32]
		$NewRUs,


		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$AppServicePlans,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Tier,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Int32]
		$NumberofWorkers,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$WorkerSize,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.Boolean]
		$PerSiteScaling
	)

	"Starting..." | Write-Output

	$ErrorActionPreference = "Stop"
	$WarningPreference = "Continue"
	$VerbosePreference = "Continue"

	# Ensures you do not inherit an AzContext in your runbook
	$Autosave = Disable-AzContextAutosave –Scope Process

	$Connection = Get-AutomationConnection -Name AzureRunAsConnection
	$ConnectionResult = Connect-AzAccount -ServicePrincipal -Tenant $Connection.TenantID -ApplicationId $Connection.ApplicationID -CertificateThumbprint $Connection.CertificateThumbprint

	$Context = Set-AzContext -SubscriptionId $SubscriptionId

	"Invoking Scale-UpDown-AzureVM..." | Write-Output

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

	"Invoked Scale-UpDown-AzureVM." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureSqlElasticPool..." | Write-Output

	$ElasticPool = Get-AzSqlElasticPool -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $ElasticPoolName

	"Elastic Pool name: $($ElasticPool.ElasticPoolName)" | Write-Output
	"Current Elastic Pool status: $($ElasticPool.State)" | Write-Output

	if ($Null -ne $ElasticPool) {
		"Scaling the Elastic Pool: $($ElasticPool.ElasticPoolName)" | Write-Output

		$ElasticPool | Set-AzSqlElasticPool -Dtu $Dtu -DatabaseDtuMax $DatabaseDtuMax -DatabaseDtuMin $DatabaseDtuMin -StorageMB $StorageMB | Write-Output

		"Elastic Pool scaling task complete." | Write-Output
	} 
	else {
		"Elastic Pool unavailable. Please retry." | Write-Error
	}

	"Invoked Scale-UpDown-AzureSqlElasticPool." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureCosmosDb..." | Write-Output

	$Throughput = Get-AzCosmosDBSqlContainerThroughput -ResourceGroupName $ResourceGroupName -AccountName $AccountName -DatabaseName $DatabaseName -Name $ContainerName

	$CurrentRUs = $Throughput.Throughput
	$MinimumRUs = $Throughput.MinimumThroughput

	"Current throughput is $CurrentRUs. Minimum allowed throughput is $MinimumRUs." | Write-Output

	if ([int]$NewRUs -lt [int]$MinimumRUs) {
		"Requested new throughput of $NewRUs is less than minimum allowed throughput of $MinimumRUs." | Write-Output
		"Using minimum allowed throughput of $MinimumRUs instead." | Write-Output
		$NewRUs = $MinimumRUs
	}


	if ([int]$NewRUs -eq [int]$CurrentRUs) {
		"New throughput is the same as current throughput. No change needed." | Write-Output
	}
	else {
		"Updating throughput to $NewRUs." | Write-Output

		Get-AzCosmosDBSqlContainer -ResourceGroupName $ResourceGroupName -AccountName $AccountName -DatabaseName $DatabaseName -Name $ContainerName | Update-AzCosmosDBSqlContainerThroughput -Throughput $NewRUs | Write-Output
	}

	"Invoked Scale-UpDown-AzureCosmosDb." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureAppServicePlan..." | Write-Output

	if ($AppServicePlans -notlike "All") {
		$AppServicePlansToHandle = $AppServicePlans.Split(",")
	} 
	else {
		$AppServicePlansToHandle = @(Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName).Name
	}
	"Azure App Service Plans: $AppServicePlansToHandle" | Write-Output

	foreach ($AppServicePlan in $AppServicePlansToHandle) {
		if (!(Get-AzAppServicePlan | Where-Object { $_.Name -like $AppServicePlan })) {
			"Azure App Service Plan : [$AppServicePlan] - Does not exist! - Check your inputs" | Write-Error
		}
	}

	foreach	($AppServicePlan in $AppServicePlansToHandle) {
		$AppServicePlanObj = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlan

		"App Service Plan name: $($AppServicePlanObj.Name)" | Write-Output
		"Current App Service Plan status: $($AppServicePlanObj.Status), tier: $($AppServicePlanObj.Sku.Name)" | Write-Output
		"Scaling the App Service Plan: $($AppServicePlan)" | Write-Output

		Set-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlan -Tier $Tier -NumberofWorkers $NumberofWorkers -WorkerSize $WorkerSize -PerSiteScaling $PerSiteScaling | Write-Output

		"App Service Plan scaling task complete." | Write-Output
	}

	"Invoked Scale-UpDown-AzureAppServicePlan." | Write-Output
}