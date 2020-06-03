workflow Scale-UpDown-AzureSqlElasticPool {
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
		$StorageMB
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

	"End of script!" | Write-Output
}