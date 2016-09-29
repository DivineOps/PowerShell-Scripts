# All variables need to be defined in automation account

$SPAppID = Get-AutomationVariable -Name 'ApplicationId'
$SPTenant = Get-AutomationVariable -Name 'TenantId'
$SubscriptionId = Get-AutomationVariable 'SubscriptionId'
$Certificate = Get-AutomationCertificate -Name 'azureautomationcert'
$CertThumbprint = ($Certificate.Thumbprint).ToString()    

$CertThumbprint 
$SPAppID

#Log into Azure ARM
Login-AzureRmAccount -ServicePrincipal -TenantId $SPTenant -CertificateThumbprint $CertThumbprint -ApplicationId $SPAppID 
#Select Subscription ARM
Select-AzureRmSubscription -SubscriptionId $SubscriptionId -TenantId $SPTenant

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

#Get all VM Scale Sets
$vmssList = Get-AzureRmVmss

#Attempt to stop all VMSS
foreach($vmss in $vmssList){  
	#I have no indication of the running state sadly
	
	# Extract ResourceGroupName from resource ID
	$stdout = $vmss.Id -match ".*resourceGroups/(?<rgName>.*)/providers.*";
	$rgName = $matches['rgName']

	Write-Output "Stopping VMSS [$($vmss.Name)], ResourceGroupName [$($rgName)]"
	Stop-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $vmss.Name	
}

