
####################################################
# Cleanup
####################################################

#remove vms
Remove-AzureRmVM -ResourceGroupName $RgName -Name $VMName[$i]

#Remove Storage

# Remove VNet


# Remove resource group
Remove-AzureRmResourceGroup -Name DmzRG 
