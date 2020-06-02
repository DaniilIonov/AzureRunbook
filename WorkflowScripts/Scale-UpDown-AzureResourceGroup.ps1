workflow Scale-UpDown-AzureResourceGroup {
    [OutputType([System.Void])]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $subscriptionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $resourceGroupName,


        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $vmName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $vmSize,


        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $serverName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $elasticPoolName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $dtu,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $databaseDtuMax,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $databaseDtuMin,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $storageMB,


        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $accountName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $databaseName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $containerName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $newRUs,


        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $appServicePlans,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Free', 'Shared', 'Basic', 'Standard', 'Premium')]
        [String]
        $tier,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Int32]
        $numberofWorkers,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Small', 'Medium', 'Large', 'ExtraLarge')]
        [String]
        $workerSize,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
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