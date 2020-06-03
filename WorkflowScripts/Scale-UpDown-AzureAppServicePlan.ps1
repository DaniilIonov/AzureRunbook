workflow Scale-UpDown-AzureAppServicePlan {
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

	$ErrorActionPreference = "Stop"
	$WarningPreference = "Continue"
	$VerbosePreference = "Continue"

	"Starting..." | Write-Output

	# Ensures you do not inherit an AzContext in your runbook
	$Autosave = Disable-AzContextAutosave –Scope Process

	$Connection = Get-AutomationConnection -Name AzureRunAsConnection
	$ConnectionResult = Connect-AzAccount -ServicePrincipal -Tenant $Connection.TenantID -ApplicationId $Connection.ApplicationID -CertificateThumbprint $Connection.CertificateThumbprint

	$Context = Set-AzContext -SubscriptionId $SubscriptionId

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

	"End of script!" | Write-Output
}