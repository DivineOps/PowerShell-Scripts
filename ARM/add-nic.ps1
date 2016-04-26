$vmName = "win16"
$vmRg = "VmFarm"
$nicName = "second"
$nicRG = "VmFarm"

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $vmRg

$secondNic =  Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $nicRG

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $secondNic.Id

$vm.NetworkProfile.NetworkInterfaces

#we have to set one of the NICs to Primary, i will set the first NIC in this example
$vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true

Update-AzureRmVM -VM $vm -ResourceGroupName $vmRg