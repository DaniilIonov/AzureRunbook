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
		$VmName,

		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$VmSize,


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

	"Invoking Scale-UpDown-AzureVM..." | Write-Output
	Scale-UpDown-AzureVM -subscriptionId $SubscriptionId -resourceGroupName $ResourceGroupName -vmName $VmName -vmSize $VmSize
	"Invoked Scale-UpDown-AzureVM." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureSqlElasticPool..." | Write-Output
	Scale-UpDown-AzureSqlElasticPool -subscriptionId $SubscriptionId -resourceGroupName $ResourceGroupName -serverName $ServerName -elasticPoolName $ElasticPoolName -dtu $Dtu -databaseDtuMax $DatabaseDtuMax -databaseDtuMin $DatabaseDtuMin -storageMB $StorageMB
	"Invoked Scale-UpDown-AzureSqlElasticPool." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureCosmosDb..." | Write-Output
	Scale-UpDown-AzureCosmosDb -subscriptionId $SubscriptionId -resourceGroupName $ResourceGroupName -accountName $AccountName -databaseName $DatabaseName -containerName $ContainerName -newRUs $NewRUs
	"Invoked Scale-UpDown-AzureCosmosDb." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureAppServicePlan..." | Write-Output
	Scale-UpDown-AzureAppServicePlan -subscriptionId $SubscriptionId -appServicePlans $AppServicePlans -resourceGroupName $ResourceGroupName -tier $Tier -numberofWorkers $NumberofWorkers -workerSize $WorkerSize -perSiteScaling $PerSiteScaling
	"Invoked Scale-UpDown-AzureAppServicePlan." | Write-Output
}