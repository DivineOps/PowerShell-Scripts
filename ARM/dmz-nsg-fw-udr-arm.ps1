####################################################
# Variables
####################################################
# Fixed Variables
	
	#set up credentials for local admin on all VMs
	$Credential = Get-Credential
	$RgName = "DmzRg"
    $DeploymentLocation = "northcentralus"
	#has to be unique!
    $StorageAccountName = "sashadmzstorage"
	
	#Arrays of VM params
	$VMName = @()
	$AvSetName = @()
	$VMFamily = @()
	$img = @()
	$size = @()
	$SubnetName = @()
	$VMIP = @()

  # Network Details
    $VNetName = "DmzVNet"
    $VNetPrefix = "10.0.0.0/16"
    $SecSubnetName = "SecNet"
	$SecNetPrefix = "10.0.0.0/24"
    $FESubnetName = "FrontEnd"
    $FEPrefix = "10.0.1.0/24"
    $BESubnetName = "BackEnd"
    $BEPrefix = "10.0.2.0/24"
    $NetworkConfigFile = "C:\Scripts\NetworkConf3.xml"

# User Defined VM Specific Config
    # Note: To ensure UDR and IP forwarding is setup
    # properly this script requires VM 0 be the NVA.

    # VM 0 - The Network Virtual Appliance (NVA)
      $VMName += "myFirewall"
      $VMFamily += "Firewall"
      $img += $FWImg
      $size += "Small"
      $SubnetName += $SecSubnetName
      $VMIP += "10.0.0.4"

    # VM 1 - The Web Server
      $VMName += "IIS01"
	  $AvSetName += "IIS_AvSet"
	  $ComputerName += ($VMName | Select-Object -Last 1) 
	  $InterfaceName += ($VMName | Select-Object -Last 1) + "_Nic1"
	  $OSDiskName += ($VMName | Select-Object -Last 1) + "_OSDisk"
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $FESubnetName
      $VMIP += "10.0.1.4"

    # VM 2 - The First Appliaction Server
      $VMName += "AppVM01"
	  $AvSetName += "App_AvSet"
	  $ComputerName += ($VMName | Select-Object -Last 1) 
	  $InterfaceName += ($VMName | Select-Object -Last 1) + "_Nic1"
	  $OSDiskName += ($VMName | Select-Object -Last 1) + "_OSDisk"
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $BESubnetName
      $VMIP += "10.0.2.5"

    # VM 3 - The Second Appliaction Server
      $VMName += "AppVM02"
	  $AvSetName += "App_AvSet"
	  $ComputerName += ($VMName | Select-Object -Last 1) 
	  $InterfaceName += ($VMName | Select-Object -Last 1) + "_Nic1"
	  $OSDiskName += ($VMName | Select-Object -Last 1) + "_OSDisk"
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $BESubnetName
      $VMIP += "10.0.2.6"

    # VM 4 - The DNS Server
      $VMName += "DNS01"
	  $AvSetName += "Dns_AvSet"
	  $ComputerName += ($VMName | Select-Object -Last 1) 
	  $InterfaceName += ($VMName | Select-Object -Last 1) + "_Nic1"
	  $OSDiskName += ($VMName | Select-Object -Last 1) + "_OSDisk"
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $BESubnetName
      $VMIP += "10.0.2.4"
	  
	  <#
#get standard VM image
$vmImageId = Get-AzureRmVMImage -Location $DeploymentLocation -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -SKUs "2012-r2-Datacenter" | Sort Version -Descending | Select Id -First 1
#get barracuda firewall image
$barracudaImageId = Get-AzureRmVMImage -Location $DeploymentLocation -PublisherName "barracudanetworks" -Offer "barracuda-ng-firewall" -SKUs "hourly" | Sort Version -Descending | Select Id -First 1
#>

####################################################
# Create
####################################################
#Create resource group
New-AzureRmResourceGroup -Name $RgName -Location $DeploymentLocation

# Create VNet subnet mask 255.255.0.0, 65,536 IPs
New-AzureRmVirtualNetwork -ResourceGroupName $RgName -Name DmzVNet -AddressPrefix $VNetPrefix -Location $DeploymentLocation   

# Add Security, front end and backend subnets
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $RgName -Name $VNetName

$secSubnet = Add-AzureRmVirtualNetworkSubnetConfig -Name $SecNetName -VirtualNetwork $vnet -AddressPrefix $SecNetPrefix
$FESubnet = Add-AzureRmVirtualNetworkSubnetConfig -Name $FESubnetName -VirtualNetwork $vnet -AddressPrefix $FEPrefix
$BESubnet = Add-AzureRmVirtualNetworkSubnetConfig -Name $BESubnetName -VirtualNetwork $vnet -AddressPrefix $BEPrefix

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet 

#Create storage
#this succeeds if the account already exists
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $RgName -AccountName $StorageAccountName -Type "Standard_LRS" -Location $DeploymentLocation


	
	
#Create VMs
# Build VMs
$i=0
$VMName | Foreach {
	Write-Host "Building $($VMName[$i])" -ForegroundColor Cyan
	If ($VMFamily[$i] -eq "Firewall") 
		{ 
		<#New-AzureRmVMConfig -Name $VMName[$i] -ImageName $img[$i] –InstanceSize $size[$i] | `
			Add-AzureProvisioningConfig -Linux -LinuxUser $LocalAdmin -Password $LocalAdminPwd  | `
			Set-AzureSubnet  –SubnetNames $SubnetName[$i] | `
			Set-AzureStaticVNetIP -IPAddress $VMIP[$i] | `
			New-AzureVM –ServiceName $ServiceName[$i] -VNetName $VNetName -Location $DeploymentLocation
		# Set up all the EndPoints we'll need once we're up and running
		# Note: All traffic goes through the firewall, so we'll need to set up all ports here.
		#       Also, the firewall will be redirecting traffic to a new IP and Port in a forwarding
		#       rule, so all of these endpoint have the same public and local port and the firewall
		#       will do the mapping, NATing, and/or redirection as declared in the firewall rules.
		Add-AzureEndpoint -Name "MgmtPort1" -Protocol tcp -PublicPort 801  -LocalPort 801  -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		Add-AzureEndpoint -Name "MgmtPort2" -Protocol tcp -PublicPort 807  -LocalPort 807  -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		Add-AzureEndpoint -Name "HTTP"      -Protocol tcp -PublicPort 80   -LocalPort 80   -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		Add-AzureEndpoint -Name "RDPWeb"    -Protocol tcp -PublicPort 8014 -LocalPort 8014 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		Add-AzureEndpoint -Name "RDPApp1"   -Protocol tcp -PublicPort 8025 -LocalPort 8025 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		Add-AzureEndpoint -Name "RDPApp2"   -Protocol tcp -PublicPort 8026 -LocalPort 8026 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		Add-AzureEndpoint -Name "RDPDNS01"  -Protocol tcp -PublicPort 8024 -LocalPort 8024 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
		#>
		# Note: A SSH endpoint is automatically created on port 22 when the appliance is created.
		}
	Else
		{
			#create availability set
			$avset = New-AzureRmAvailabilitySet -ResourceGroupName $RgName -Name $AvSetName[$i] -Location $DeploymentLocation
			
			#create NIC
			$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName[$i] -VirtualNetwork $vnet
			$Interface = New-AzureRmNetworkInterface -Name $InterfaceName[$i] -ResourceGroupName $RgName -Location $DeploymentLocation -SubnetId $subnet.Id 

			#set the OS VHD URI
			$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName[$i] + ".vhd"
			
			#Specify complete VM config
			$vmConfig = New-AzureRmVMConfig -VMName $VMName[$i] -VMSize $size[$i] -AvailabilitySetId $avset.Id | `
				Set-AzureRmVMOperatingSystem -Windows -ComputerName $ComputerName[$i] -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate | `
				Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest" | `
				Set-AzureRmVMOSDisk -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage | `
				Add-AzureRmVMNetworkInterface -Id $Interface.Id
			
			#Create VM
			$vm = New-AzureRmVM -ResourceGroupName $RgName -Location $DeploymentLocation -VM $vmConfig
		}
	$i++
}