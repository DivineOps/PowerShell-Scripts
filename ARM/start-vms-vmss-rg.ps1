
# Get RG name from input
 param (
    [Parameter(Mandatory=$true)][string]$rgName
 )
 
Get-AzureRmResourceGroup -Name $rgName -ev notPresent -ea 0

if ($notPresent)
{
    # ResourceGroup doesn't exist
	Write-Output "Resource Group doesn't exist. Exiting"
	exit
}

Write-Output "Starting VMs and VMSS in Resource Group [$($rgName)]]"


# Get a list of Azure VMs
$vmList = Get-AzureRmVM -ResourceGroupName $rgName
Write-Output "Number of Virtual Machines found in RG: [$($vmList.Count)] Name(s): [$($vmList.name  -join ", ")]"

# Start all VMs in ResourceGroup
foreach($vm in $vmList){   
	$vmStatus = Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
	# Start VMs
	if($vmStatus.Statuses | where Code -match "PowerState/deallocated")  
	{
		Write-Output "Starting VM [$($vm.Name)]"
		$vm | Start-AzureRmVM 
	}
	else {
		Write-Output "VM [$($vm.Name)] is already started!"
	}
}

#Get all VM Scale Sets
$vmssList = Get-AzureRmVmss

#Attempt to stop all VMSS
foreach($vmss in $vmssList){  
	#I have no indication of the running state sadly

	Write-Output "Starting VMSS [$($vmss.Name)], ResourceGroupName [$($rgName)]"
	Start-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $vmss.Name	
}
