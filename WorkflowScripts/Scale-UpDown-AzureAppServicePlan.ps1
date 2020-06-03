workflow Scale-UpDown-AzureAppServicePlan {
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $true)]
		[System.String]
		$subscriptionId,

		[Parameter(Mandatory = $true)]
		[System.String]
		$resourceGroupName,

		[Parameter(Mandatory = $true)]
		[System.String]
		$appServicePlans,

		[Parameter(Mandatory = $true)]
		[System.String]
		$tier,

		[Parameter(Mandatory = $true)]
		[System.Int32]
		$numberofWorkers,

		[Parameter(Mandatory = $true)]
		[System.String]
		$workerSize,

		[Parameter(Mandatory = $true)]
		[System.Boolean]
		$perSiteScaling
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

	if ($appServicePlans -notlike "All") {
		$appServicePlansToHandle = $appServicePlans.Split(",")
	} 
	else {
		$appServicePlansToHandle = @(Get-AzAppServicePlan -ResourceGroupName $resourceGroupName).Name
	}
	"Azure App Service Plans: $appServicePlansToHandle" | Write-Output

	foreach ($appServicePlan in $appServicePlansToHandle) {
		if (!(Get-AzAppServicePlan | Where-Object { $_.Name -like $appServicePlan })) {
			"Azure App Service Plan : [$appServicePlan] - Does not exist! - Check your inputs" | Write-Error
		}
	}

	foreach	($appServicePlan in $appServicePlansToHandle) {
		$appServicePlanObj = Get-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $appServicePlan

		"App Service Plan name: $($appServicePlanObj.Name)" | Write-Output
		"Current App Service Plan status: $($appServicePlanObj.Status), tier: $($appServicePlanObj.Sku.Name)" | Write-Output
		"Scaling the App Service Plan: $($appServicePlan)" | Write-Output

		Set-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $appServicePlan -Tier $tier -NumberofWorkers $numberofWorkers -WorkerSize $workerSize -PerSiteScaling $perSiteScaling | Write-Output

		"App Service Plan scaling task complete." | Write-Output
	}

	"End of script!" | Write-Output
}