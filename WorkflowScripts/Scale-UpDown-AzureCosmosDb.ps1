workflow Scale-UpDown-AzureCosmosDb {
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
    	$newRUs
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

	$throughput = Get-AzCosmosDBSqlContainerThroughput -ResourceGroupName $resourceGroupName -AccountName $accountName -DatabaseName $databaseName -Name $containerName

	$currentRUs = $throughput.Throughput
	$minimumRUs = $throughput.MinimumThroughput

	"Current throughput is $currentRUs. Minimum allowed throughput is $minimumRUs." | Write-Output

	if ([int]$newRUs -lt [int]$minimumRUs) {
		"Requested new throughput of $newRUs is less than minimum allowed throughput of $minimumRUs." | Write-Output
		"Using minimum allowed throughput of $minimumRUs instead." | Write-Output
		$newRUs = $minimumRUs
	}


	if ([int]$newRUs -eq [int]$currentRUs) {
		"New throughput is the same as current throughput. No change needed." | Write-Output
	}
	else {
		"Updating throughput to $newRUs." | Write-Output

		Get-AzCosmosDBSqlContainer -ResourceGroupName $resourceGroupName -AccountName $accountName -DatabaseName $databaseName -Name $containerName | Update-AzCosmosDBSqlContainerThroughput -Throughput $newRUs | Write-Output
	}

	"End of script!" | Write-Output
}