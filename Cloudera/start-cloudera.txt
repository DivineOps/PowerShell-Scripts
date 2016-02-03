####################### Variables ########################################

$username = "cmadmin" #TODO replace with cloudera username
$password = ConvertTo-SecureString "mySecureP@wd" -AsPlainText -Force  #TODO replace with cloudera password

$clouderaRG = "acepoc" #TODO replace with resource group name where the cluster is deployed
$clusterName = "acepoc" #TODO replace with cloudera cluster name
$mn0 = $clusterName + "-mn0"

$sleepTimeout = 180

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

#Start all VMs
Write-Output "Starting VMs in Resource Group [$($clouderaRG.ResourceGroupName)]"
# Get a list of Azure VMs
$vmList = Get-AzureRmVM -ResourceGroupName $clouderaRG
Write-Output "Number of Virtual Machines found in RG: [$($vmList.Count)] Name(s): [$($vmList.name  -join ", ")]"

# Start all stopped VMs in ResourceGroup
foreach($vm in $vmList){   
	$vmStatus = Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
	# Start stopped VMs
	if($vmStatus.Statuses | where Code -match "PowerState/deallocated")  
	{
		Write-Output "Starting VM [$($vm.Name)]"
		$vm | Start-AzureRmVM 
	}
	else {
		Write-Output "VM [$($vm.Name)] is already running!"
	}
}

#Wait to make sure VMs have time to come up
Start-Sleep -s $sleepTimeout 

# Verify that mn0 is up
$mn0Status = Get-AzureRmVM -ResourceGroupName $clouderaRG -Name $mn0 -Status
if($mn0Status.Statuses | where Code -match "PowerState/running")  
{
	$cManagerStatus = Invoke-RestMethod -Uri $cmStatusUri -Method Get -Credential $cred
	if($cManagerStatus.entityStatus -eq "GOOD_HEALTH")  
	{
		# Check cloudera cluster status
		$status = Invoke-RestMethod -Uri $statusUri -Method Get -Credential $cred
		if($status.entityStatus -ne "GOOD_HEALTH"){
			#start the cluster if it wasn't running
			Invoke-RestMethod -Uri $startUri -Method Post -Credential $cred
		} else{
			Write-Output "Cloudera cluster is already running"
		}
	} else {
	
		#Restart Cloudera Manager
		Write-Output "Restarting Cloudera manager"
		Invoke-RestMethod -Uri $cmRestartUri -Method Post -Credential $cred
		
		#Sleep to let CM come back up
		Start-Sleep -s $sleepTimeout 
	
		#Check CM status again
		$cManagerStatus = Invoke-RestMethod -Uri $cmStatusUri -Method Get -Credential $cred
		if($cManagerStatus.entityStatus -eq "GOOD_HEALTH")  
		{
			# Check cloudera cluster status
			$status = Invoke-RestMethod -Uri $statusUri -Method Get -Credential $cred
			if($status.entityStatus -ne "GOOD_HEALTH"){
				#start the cluster if it wasn't running
				Invoke-RestMethod -Uri $startUri -Method Post -Credential $cred
			} else{
				Write-Output "Cloudera cluster is already running"
			}
		} else {
			Write-Output "Failed to start Cloudera Manager. Cannot start Cloudera cluster"
		}
	} 
} else {
	Write-Output "Failed to start mn0. Cannot start Cloudera cluster"
}

#Wait to make sure the cluster comes up
Start-Sleep -s $sleepTimeout 

#Make sure the cluster is up
$status = Invoke-RestMethod -Uri $statusUri -Method Get -Credential $cred
if($status.entityStatus -eq "GOOD_HEALTH"){
	Write-Output "Started the cluster successfully"
} else {
	Write-Output "Epic fail! Could not start the cloudera cluster!!!"
}

