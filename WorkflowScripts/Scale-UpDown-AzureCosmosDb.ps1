﻿workflow Scale-UpDown-AzureCosmosDb {
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $True)]
		[System.String]
		$SubscriptionId,

		[Parameter(Mandatory = $True)]
		[System.String]
		$ResourceGroupName,

		[Parameter(Mandatory = $True)]
		[System.String]
		$AccountName,

		[Parameter(Mandatory = $True)]
		[System.String]
		$DatabaseName,

		[Parameter(Mandatory = $True)]
		[System.String]
		$ContainerName,

		[Parameter(Mandatory = $True)]
		[System.Int32]
		$NewRUs
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

	"End of script!" | Write-Output
}