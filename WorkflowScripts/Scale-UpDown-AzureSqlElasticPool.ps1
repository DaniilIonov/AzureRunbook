workflow Scale-UpDown-AzureSqlElasticPool {
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
		$storageMB
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

	$elasticPool = Get-AzSqlElasticPool -ResourceGroupName $resourceGroupName -ServerName $serverName -ElasticPoolName $elasticPoolName

	"Elastic Pool name: $($elasticPool.ElasticPoolName)" | Write-Output
	"Current Elastic Pool status: $($elasticPool.State)" | Write-Output

	if ($null -ne $elasticPool) {
		"Scaling the Elastic Pool: $($elasticPool.ElasticPoolName)" | Write-Output

		$elasticPool | Set-AzSqlElasticPool -Dtu $dtu -DatabaseDtuMax $databaseDtuMax -DatabaseDtuMin $databaseDtuMin -StorageMB $storageMB | Write-Output

		"Elastic Pool scaling task complete." | Write-Output
	} 
	else {
		"Elastic Pool unavailable. Please retry." | Write-Error
	}

	"End of script!" | Write-Output
}