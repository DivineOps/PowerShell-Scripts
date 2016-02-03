####################### Variables ########################################

$username = "cmadmin" #TODO replace with cloudera username
$password = ConvertTo-SecureString "mySecureP@wd" -AsPlainText -Force  #TODO replace with cloudera password

$clouderaRG = "acepoc" #TODO replace with resource group name where the cluster is deployed
$clusterName = "acepoc" #TODO replace with cloudera cluster name
$mn0 = $clusterName + "-mn0"

$sleepTimeout = 120

$baseUrl = "http://acepoc-mn0.westeurope.cloudapp.azure.com:7180/api/v11/" #TODO replace acepoc-mn0.westeurope with the correct URL prefix

$statusUri = $baseUrl + "clusters/$($clusterName)"
$stopUri = $baseUrl + "clusters/$($clusterName)/commands/stop"
$startUri = $baseUrl + "clusters/$($clusterName)/commands/start"
$hdfsStatusUri = $baseUrl + "clusters/$($clusterName)/services/hdfs"
$cmStatusUri = $baseUrl + "cm/service"
$cmRestartUri = $baseUrl + "cm/service/commands/restart"


############################################################################


# create cloudera API credentials
$cred =  New-Object System.Management.Automation.PSCredential ($username, $password)

# Check cloudera cluster status
$status = Invoke-RestMethod -Uri $statusUri -Method Get -Credential $cred
if($status.entityStatus -ne "STOPPED"){
	#stop the cluster if it was running
	Write-Output "Stopping the cluster"
	Invoke-RestMethod -Uri $stopUri -Method Post -Credential $cred
} else{
	Write-Output "Cloudera cluster is already stopped"
}

#Wait to make sure that the service has time to stop
Start-Sleep -s $sleepTimeout 

#If the service was successfully stopped, stop the VMs
$status = Invoke-RestMethod -Uri $statusUri -Method Get -Credential $cred
if($status.entityStatus -eq "STOPPED"){
	
	#stop all VMs
	Write-Output "Stopping VMs in Resource Group [$($clouderaRG.ResourceGroupName)]"
	# Get a list of Azure VMs
	$vmList = Get-AzureRmVM -ResourceGroupName $clouderaRG
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
	
} else{
	#fail
	Write-Output "Epic fail!!! Cloudera cluster failed to stop!!! Cannot shut down VMs!!!"
}


