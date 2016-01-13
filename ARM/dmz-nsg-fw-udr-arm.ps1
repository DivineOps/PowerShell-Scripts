####################################################
# Variables
####################################################
    $LocalAdminPwd = Read-Host -Prompt "Enter Local Admin Password to be used for all VMs"
    $VMName = @()
    $ServiceName = @()
    $VMFamily = @()
    $img = @()
    $size = @()
    $SubnetName = @()
    $VMIP = @()

####################################################
# Create
####################################################
#Create resource group
New-AzureRmResourceGroup -Name DmzRG -Location northcentralus

# Create VNet subnet mask 255.255.0.0, 65,536 IPs
New-AzureRmVirtualNetwork -ResourceGroupName DmzRG -Name DmzVNet -AddressPrefix 10.0.0.0/16 -Location northcentralus   

# Add Security, front end and backend subnets
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName DmzRG -Name DmzVNet

Add-AzureRmVirtualNetworkSubnetConfig -Name Security -VirtualNetwork $vnet -AddressPrefix 10.0.0.0/24
Add-AzureRmVirtualNetworkSubnetConfig -Name FrontEnd -VirtualNetwork $vnet -AddressPrefix 10.0.1.0/24
Add-AzureRmVirtualNetworkSubnetConfig -Name BackEnd -VirtualNetwork $vnet -AddressPrefix 10.0.2.0/24

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet 


####################################################
# Cleanup
####################################################

# Remove VNet


# Remove resource group
Remove-AzureRmResourceGroup -Name DmzRG 
