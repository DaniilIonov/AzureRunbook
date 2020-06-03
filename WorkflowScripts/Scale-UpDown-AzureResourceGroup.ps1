workflow Scale-UpDown-AzureResourceGroup {
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
        $vmName,

        [Parameter(Mandatory = $true)]
		[String]
        $vmSize,


        [Parameter(Mandatory = $true)]
		[String]
        $serverName,

        [Parameter(Mandatory = $true)]
		[String]
        $elasticPoolName,

        [Parameter(Mandatory = $true)]
		[Int32]
        $dtu,

        [Parameter(Mandatory = $true)]
		[Int32]
        $databaseDtuMax,

        [Parameter(Mandatory = $true)]
		[Int32]
        $databaseDtuMin,

        [Parameter(Mandatory = $true)]
		[Int32]
        $storageMB,


        [Parameter(Mandatory = $true)]
		[String]
        $accountName,

        [Parameter(Mandatory = $true)]
		[String]
        $databaseName,

        [Parameter(Mandatory = $true)]
		[String]
        $containerName,

        [Parameter(Mandatory = $true)]
		[Int32]
        $newRUs,


        [Parameter(Mandatory = $true)]
		[String]
        $appServicePlans,

        [Parameter(Mandatory = $true)]
		[String]
        $tier,

        [Parameter(Mandatory = $true)]
		[Int32]
        $numberofWorkers,

        [Parameter(Mandatory = $true)]
		[String]
        $workerSize,

        [Parameter(Mandatory = $true)]
		[Boolean]
        $perSiteScaling
    )

    "Starting..." | Write-Output

    "Invoking Scale-UpDown-AzureVM..." | Write-Output
    Scale-UpDown-AzureVM -subscriptionId $subscriptionId -resourceGroupName $resourceGroupName -vmName $vmName -vmSize $vmSize
    "Invoked Scale-UpDown-AzureVM." | Write-Output

    Checkpoint-Workflow

    "Invoking Scale-UpDown-AzureSqlElasticPool..." | Write-Output
    Scale-UpDown-AzureSqlElasticPool -subscriptionId $subscriptionId -resourceGroupName $resourceGroupName -serverName $serverName -elasticPoolName $elasticPoolName -dtu $dtu -databaseDtuMax $databaseDtuMax -databaseDtuMin $databaseDtuMin -storageMB $storageMB
    "Invoked Scale-UpDown-AzureSqlElasticPool." | Write-Output

    Checkpoint-Workflow

    "Invoking Scale-UpDown-AzureCosmosDb..." | Write-Output
    Scale-UpDown-AzureCosmosDb -subscriptionId $subscriptionId -resourceGroupName $resourceGroupName -accountName $accountName -databaseName $databaseName -containerName $containerName -newRUs $newRUs
    "Invoked Scale-UpDown-AzureCosmosDb." | Write-Output

    Checkpoint-Workflow

    "Invoking Scale-UpDown-AzureAppServicePlan..." | Write-Output
    Scale-UpDown-AzureAppServicePlan -subscriptionId $subscriptionId -appServicePlans $appServicePlans -resourceGroupName $resourceGroupName -tier $tier -numberofWorkers $numberofWorkers -workerSize $workerSize -perSiteScaling $perSiteScaling
    "Invoked Scale-UpDown-AzureAppServicePlan." | Write-Output
}