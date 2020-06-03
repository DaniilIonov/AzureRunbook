workflow Stop-Start-AzureVM {
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
    	$azureVMList,

    	[Parameter(Mandatory = $true)]
		[String]
    	$action
    )

    $ErrorActionPreference = "Stop"
    $WarningPreference = "Continue"
    $VerbosePreference = "Continue"

    $supportedActions = "Start", "Stop"
    if ($supportedActions -notContains $action) {
        "Action not supported: $action" | Write-Error
    }

    "Starting..." | Write-Output

    # Ensures you do not inherit an AzContext in your runbook
    $autosave = Disable-AzContextAutosave –Scope Process

    $connection = Get-AutomationConnection -Name AzureRunAsConnection
    $connectionResult = Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

    $context = Set-AzContext -SubscriptionId $subscriptionId

    if ($azureVMList -notlike "All") {
        $azureVMsToHandle = $azureVMList.Split(",")
    }
    else {
        $azureVMsToHandle = @(Get-AzVM -ResourceGroupName $resourceGroupName).Name
    }
    "Azure VMs: $azureVMsToHandle" | Write-Output

    foreach ($azureVM in $azureVMsToHandle) {
        if ($null -eq $(Get-AzVM -Name $azureVM)) {
            "AzureVM : [$azureVM] - Does not exist! - Check your inputs" | Write-Error
        } 
    }

    if ($action -like "Stop") {
        "Stopping VMs:" | Write-Output

        foreach ($azureVM in $azureVMsToHandle) {
            "Stopping the VM: $azureVM" | Write-Output
            Get-AzVM -Name $azureVM | Stop-AzVM -Force | Write-Output
        }
    } 
    else {
        "Starting VMs:" | Write-Output

        foreach ($azureVM in $azureVMsToHandle) {
            "Starting the VM: $azureVM" | Write-Output
            Get-AzVM -Name $azureVM | Start-AzVM | Write-Output
        }
    } 

    "End of script!" | Write-Output
}