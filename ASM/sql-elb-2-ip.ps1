
Get-AzureService -ServiceName "CsE2SPF1DBS04" | Get-AzureInternalLoadBalancer
Get-AzureVM -ServiceName "CsE2SPF1DBS04" -Name SPF1DBS-ZE2-04 | Get-AzureEndpoint
Get-AzureVM -ServiceName "CsE2SPF1DBS04" -Name SPF1DBS-ZE2-14 | Get-AzureEndpoint

# REmove the exisitng ILB
Get-AzureVM -ServiceName "CsE2SPF1DBS04"  -Name SPF1DBS-ZE2-04 | Remove-AzureEndpoint -Name "TCP51921" | Update-AzureVM

Get-AzureVM -ServiceName "CsE2SPF1DBS04"  -Name SPF1DBS-ZE2-14 | Remove-AzureEndpoint -Name "TCP51921" | Update-AzureVM

Remove-AzureInternalLoadBalancer -ServiceName "CsE2SPF1DBS04"

# Reserve IP
New-AzureReservedIP –ReservedIPName RipE2PECO1 –Location "East US 2"  
New-AzureReservedIP –ReservedIPName RipE2COMED1 –Location "East US 2" 
 
Get-AzureReservedIP

(Get-AzureDeployment -ServiceName CsE2SPF1DBS04).VirtualIPs

#Add VIP
#Add-AzureVirtualIP -VirtualIPName Vip1 -ServiceName CsE2SPF1DBS04

Add-AzureVirtualIP -VirtualIPName VipE2DMZEWS2 -ServiceName CsE2SPF1DBS04 

#Remove-AzureVirtualIP -VirtualIPName myvip -ServiceName myService

(Get-AzureDeployment -ServiceName CsE2SPF1DBS04).VirtualIPs

#Remove-AzureReservedIP -ReservedIPName "MyReservedIP"

#Add EndPoint and ACL
# create acl and add rules

$aclELB = New-AzureAclConfig

Set-AzureAclConfig  `
                -AddRule  `
                -ACL $aclELB  `
                -Order 100     `
                -Action permit  `
                -RemoteSubnet "10.0.0.0/8" `
                -Description "On-Prem Networks"

Set-AzureAclConfig  `
                -AddRule  `
                -ACL $aclELB  `
                -Order 110 `
                -Action permit  `
                -RemoteSubnet "172.26.0.0/16" `
                -Description "Azure Networks"

Get-AzureVM -ServiceName CsE2SPF1DBS04 -Name SPF1DBS-ZE2-04 | Add-AzureEndpoint -Name "TCP51923-PECO-ELB" -Protocol "TCP" -PublicPort 51923 -LocalPort 51923 -ACL $aclELB -LBSetName "SPF1CNTPECODBS-LNELB-TCP51923" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true | Update-AzureVM

Get-AzureVM -ServiceName CsE2SPF1DBS04 | Add-AzureEndpoint -Name "TCP51924-COMED-ELB" -Protocol "TCP" -PublicPort 51924 -LocalPort 51924 -ACL $aclELB -LBSetName "SPF1CNTCOMEDDBS-LNELB-TCP51924" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true -VirtualIPName VipE2DMZEWS2 | Update-AzureVM

(Get-AzureDeployment -ServiceName CsE2SPF1DBS04).VirtualIPs

Get-AzureVM -ServiceName CsE2SPF1DBS04 -Name SPF1DBS-ZE2-14 | Add-AzureEndpoint -Name "TCP51923-PECO-ELB" -Protocol "TCP" -PublicPort 51923 -LocalPort 51923 -ACL $aclELB -LBSetName "SPF1CNTPECODBS-LNELB-TCP51923" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true | Update-AzureVM

#Get-AzureVM -ServiceName CsE2SPF1DBS04 | Add-AzureEndpoint -Name "TCP51924-COMED-ELB" -Protocol "TCP" -PublicPort 51924 -LocalPort 51924 -ACL $aclELB -LBSetName "SPF1CNTCOMEDDBS-LNELB-TCP51924" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true -VirtualIPName VipE2DMZEWS2 | Update-AzureVM

(Get-AzureDeployment -ServiceName CsE2SPF1DBS04).VirtualIPs

#Associate Reservered IP to Cloud Service
Set-AzureReservedIPAssociation -ReservedIPName RipE2PECO1 -ServiceName CsE2SPF1DBS04 -VirtualIPName CsE2SPF1DBS04ContractVip

Set-AzureReservedIPAssociation -ReservedIPName RipE2COMED1 -ServiceName CsE2SPF1DBS04 -VirtualIPName VipE2DMZEWS2 

=======

#WEST REGION
Get-AzureService -ServiceName "CsW1SPF1DBS04" | Get-AzureInternalLoadBalancer
Get-AzureVM -ServiceName CsW1SPF1DBS04 -Name SPF1DBS-ZW1-24 | Get-AzureEndpoint
Get-AzureVM -ServiceName CsW1SPF1DBS04 -Name SPF1DBS-ZW1-34 | Get-AzureEndpoint

Get-AzureVM -ServiceName CsW1SPF1DBS04 -Name SPF1DBS-ZW1-24 | Remove-AzureEndpoint -Name "TCP51921" | Update-AzureVM
Get-AzureVM -ServiceName CsW1SPF1DBS04 -Name SPF1DBS-ZW1-34 | Remove-AzureEndpoint -Name "TCP51921" | Update-AzureVM
Remove-AzureInternalLoadBalancer -ServiceName "CsW1SPF1DBS04"


===================================

New-AzureReservedIP –ReservedIPName RipW1PECO1 –Location "West US"  
New-AzureReservedIP –ReservedIPName RipW1COMED1 –Location "West US" 
 
Get-AzureReservedIP

(Get-AzureDeployment -ServiceName CsW1SPF1DBS04).VirtualIPs

#Add-AzureVirtualIP -VirtualIPName Vip1 -ServiceName CsW1SPF1DBS04
Add-AzureVirtualIP -VirtualIPName Vipw1DMZEWS2 -ServiceName CsW1SPF1DBS04

#Remove-AzureVirtualIP -VirtualIPName myvip-ServiceName myService

(Get-AzureDeployment -ServiceName CsW1SPF1DBS04).VirtualIPs

#Remove-AzureReservedIP -ReservedIPName "MyReservedIP"


Get-AzureVM -ServiceName CsW1SPF1DBS04 -Name SPF1DBS-ZW1-24 | Add-AzureEndpoint -Name "TCP51923-PECO-ELB" -Protocol "TCP" -PublicPort 51923 -LocalPort 51923 -ACL $aclELB -LBSetName "SPF1CNTPECODBS-LNELB-TCP51923" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true | Update-AzureVM

Get-AzureVM -ServiceName CsW1SPF1DBS04 | Add-AzureEndpoint -Name "TCP51924-COMED-ELB" -Protocol "TCP" -PublicPort 51924 -LocalPort 51924 -ACL $aclELB -LBSetName "SPF1CNTCOMEDDBS-LNELB-TCP51924" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true -VirtualIPName Vipw1DMZEWS2 | Update-AzureVM

(Get-AzureDeployment -ServiceName CsW1SPF1DBS04).VirtualIPs

Get-AzureVM -ServiceName CsW1SPF1DBS04 -Name SPF1DBS-ZW1-34 | Add-AzureEndpoint -Name "TCP51923-PECO-ELB" -Protocol "TCP" -PublicPort 51923 -LocalPort 51923 -ACL $aclELB -LBSetName "SPF1CNTPECODBS-LNELB-TCP51923" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true | Update-AzureVM

#Get-AzureVM -ServiceName CsW1SPF1DBS04 | Add-AzureEndpoint -Name "TCP51924-COMED-ELB" -Protocol "TCP" -PublicPort 51924 -LocalPort 51924 -ACL $aclELB -LBSetName "SPF1CNTCOMEDDBS-LNELB-TCP51924" -ProbePort 59999 -ProbeProtocol "TCP" -DirectServerReturn $true -VirtualIPName Vipw1DMZEWS2 | Update-AzureVM

(Get-AzureDeployment -ServiceName CsW1SPF1DBS04).VirtualIPs

Set-AzureReservedIPAssociation -ReservedIPName RipW1PECO1 -ServiceName CsW1SPF1DBS04 -VirtualIPName CsW1SPF1DBS04ContractVip

Set-AzureReservedIPAssociation -ReservedIPName RipW1COMED1 -ServiceName CsW1SPF1DBS04 -VirtualIPName Vipw1DMZEWS2

===============
