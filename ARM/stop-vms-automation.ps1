#Set up guide for automation account and credential
#  https://azure.microsoft.com/en-us/documentation/articles/automation-configuring/

#get the powershell automation credential asset
$AutomationCredentialAssetName = "autoadmincredential"
		
# Get the credential asset with access to my Azure subscription
$Cred = Get-AutomationPSCredential -Name $AutomationCredentialAssetName

# Authenticate to Azure Service Management and Azure Resource Manager
Add-AzureAccount -Credential $Cred | Out-Null
Add-AzureRmAccount -Credential $Cred | Out-Null

# Get a list of Azure VMs
$vmList = Get-AzureRmVM 
Write-Output "Number of Virtual Machines found in subscription: [$($vmList.Count)] Name(s): [$($vmList.name  -join ", ")]"

# Stop all running VMs in ResourceGroup
foreach($vm in $vmList){   
	$vmStatus = Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
	# Stop running VMs
	if($vmStatus.Statuses | where Code -match "PowerState/running")  
	{
		Write-Output "Stopping VM [$($vm.Name)]"
		$vm | Stop-AzureRmVM -Force
	}
	else {
		Write-Output "VM [$($vm.Name)] is already deallocated!"
	}
}