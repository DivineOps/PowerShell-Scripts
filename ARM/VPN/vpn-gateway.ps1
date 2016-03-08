
New-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName VmFarm -Location 'East US' -GatewayIpAddress '216.80.110.173' -AddressPrefix '192.168.1.0/24'

$gwpip = New-AzureRmPublicIpAddress -Name gwpip -ResourceGroupName VmFarm -Location 'East US' -AllocationMethod Dynamic

$vnet = Get-AzureRmVirtualNetwork -Name VmFarmVnet -ResourceGroupName VmFarm
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id 

New-AzureRmVirtualNetworkGateway -Name VmFarmVnet -ResourceGroupName VmFarm -Location 'East US' -IpConfigurations $gwipconfig -GatewayType Vpn -VpnType RouteBased

Get-AzureRmPublicIpAddress -Name gwpip -ResourceGroupName VmFarm