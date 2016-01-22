#Set up guide for automation account and credential
#  https://azure.microsoft.com/en-us/documentation/articles/automation-configuring/

#get the powershell automation credential asset
$AutomationCredentialAssetName = "autoadmincredential"
		
# Get the credential asset with access to my Azure subscription
$Cred = Get-AutomationPSCredential -Name $AutomationCredentialAssetName

# Authenticate to Azure Service Management and Azure Resource Manager
Add-AzureAccount -Credential $Cred | Out-Null
Add-AzureRmAccount -Credential $Cred | Out-Null

# Get a list of Azure ARM VMs
$vmArmList = Get-AzureRmVM 
Write-Output "Number of ARM Virtual Machines found in subscription: [$($vmArmList.Count)] Name(s): [$($vmArmList.name  -join ", ")]"

# Stop all running ARM VMs in Subscription
foreach($vm in $vmArmList){   
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

# Get a list of Azure ASM VMs
$vmAsmList = Get-AzureVM 
Write-Output "Number of ASM Virtual Machines found in subscription: [$($vmAsmList.Count)] Name(s): [$($vmAsmList.name  -join ", ")]"

# Stop all running ASM VMs in Subscription
foreach($vm in $vmAsmList){   
	$vmStatus = Get-AzureVm -ServiceName $vm.ServiceName -Name $vm.Name
	# Stop running VMs
	if($vmStatus.PowerState -match "Started")  
	{
		Write-Output "Stopping VM [$($vm.Name)]"
		$vm | Stop-AzureVM -Force
	}
	else {
		Write-Output "VM [$($vm.Name)] is already deallocated!"
	}
}