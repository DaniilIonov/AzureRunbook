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
	Scale-UpDown-AzureVM -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -VmName $VmName -VmSize $VmSize
	"Invoked Scale-UpDown-AzureVM." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureSqlElasticPool..." | Write-Output
	Scale-UpDown-AzureSqlElasticPool -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ServerName $ServerName -ElasticPoolName $ElasticPoolName -Dtu $Dtu -DatabaseDtuMax $DatabaseDtuMax -DatabaseDtuMin $DatabaseDtuMin -StorageMB $StorageMB
	"Invoked Scale-UpDown-AzureSqlElasticPool." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureCosmosDb..." | Write-Output
	Scale-UpDown-AzureCosmosDb -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -AccountName $AccountName -DatabaseName $DatabaseName -ContainerName $ContainerName -NewRUs $NewRUs
	"Invoked Scale-UpDown-AzureCosmosDb." | Write-Output

	Checkpoint-Workflow

	"Invoking Scale-UpDown-AzureAppServicePlan..." | Write-Output
	Scale-UpDown-AzureAppServicePlan -SubscriptionId $SubscriptionId -AppServicePlans $AppServicePlans -ResourceGroupName $ResourceGroupName -Tier $Tier -NumberofWorkers $NumberofWorkers -WorkerSize $WorkerSize -PerSiteScaling $PerSiteScaling
	"Invoked Scale-UpDown-AzureAppServicePlan." | Write-Output
}