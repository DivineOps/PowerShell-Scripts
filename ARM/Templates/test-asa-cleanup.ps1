#cleanup
Remove-AzureRmNetworkInterface -Name asa1-Nic0 -ResourceGroupName VMFarm -Force
Remove-AzureRmNetworkInterface -Name asa1-Nic1 -ResourceGroupName VMFarm -Force
Remove-AzureRmNetworkInterface -Name asa1-Nic2 -ResourceGroupName VMFarm -Force
Remove-AzureRmNetworkInterface -Name asa1-Nic3 -ResourceGroupName VMFarm -Force

Remove-AzureRmPublicIpAddress -Name asa1_ip -ResourceGroupName VMFarm -Force

Remove-AzureRmNetworkSecurityGroup -Name asa1-SSH-SecurityGroup -ResourceGroupName VMFarm -Force

Remove-AzureRmRouteTable -Name asaSubnet-ASAv-RouteTable -ResourceGroupName VMFarm -Force

Remove-AzureRmRouteTable -Name internalSub1-ASAv-RouteTable  -ResourceGroupName VMFarm -Force
Remove-AzureRmRouteTable -Name internalSub2-ASAv-RouteTable  -ResourceGroupName VMFarm -Force
Remove-AzureRmRouteTable -Name internalSub3-ASAv-RouteTable  -ResourceGroupName VMFarm -Force
Remove-AzureRmRouteTable -Name internalSub4-ASAv-RouteTable  -ResourceGroupName VMFarm -Force

Remove-AzureRmStorageAccount -Name testasastorage -ResourceGroupName vmfarm