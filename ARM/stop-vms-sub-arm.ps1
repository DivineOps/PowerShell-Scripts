# Get a list of Azure Resource Groups
$rgList = Get-AzureRmResourceGroup
Write-Output "Number of Resource Groups found in subscription: [$($rgList.Count)] Name(s): [$($rgList.ResourceGroupName -join ", ")]"

foreach ($rg in $rgList){
	Write-Output "Stopping VMs in Resource Group [$($rg.ResourceGroupName)]"
	# Get a list of Azure VMs
	$vmList = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName
	Write-Output "Number of Virtual Machines found in RG: [$($vmList.Count)] Name(s): [$($vmList.name  -join ", ")]"

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
}
