#https://azure.microsoft.com/en-us/documentation/articles/vpn-gateway-howto-point-to-site-rm-ps/

$VNetName  = "VNet-sasha-sf-cluster "
$SubName = "Subnet-0"
$GWSubName = "GatewaySubnet"
$VNetPrefix1 = "10.0.0.0/16"
#cannot overlap with existing subnets address spaces
$GWSubPrefix = "10.0.1.0/26" 
$VPNClientAddressPool = "216.80.110.173/24"
$RG = "ServiceFabric"
$Location = "East US"
$DNS = "8.8.8.8"
$GWName = "SfGateway"
$GWIPName = "SfGatewayIp"
$GWIPconfName = "gwipconf"
$P2SRootCertName = "ARMP2SRootCert.cer"

#Get existing VNet
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG

#Add GW subnet to existing VNet
Add-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $GWSubPrefix -Name $GWSubName -VirtualNetwork $vnet
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

#Get GW subnet
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet

#Request Dynamic PIP for GW
$pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic
$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

#Create self signed cert
#https://azure.microsoft.com/en-us/documentation/articles/vpn-gateway-certificates-point-to-site/
#Requires SDK installed
#Requires admin rights
#makecert -sky exchange -r -n "CN=ARMP2SRootCert" -pe -a sha1 -len 2048 -ss My "ARMP2SRootCert.cer"
#Create client cert from root cert
#makecert.exe -n "CN=ARMP2SClientCert" -pe -sky exchange -m 96 -ss My -in "ARMP2SRootCert" -is my -a sha1

#Upload root certificate
$MyP2SRootCertPubKeyBase64 = "MIIDAjCCAe6gAwIBAgIQtAxj12p7aYVGXjyfs+CKaDAJBgUrDgMCHQUAMBkxFzAVBgNVBAMTDkFSTVAyU1Jvb3RDZXJ0MB4XDTE2MDYxNTE3MjQyOVoXDTM5MTIzMTIzNTk1OVowGTEXMBUGA1UEAxMOQVJNUDJTUm9vdENlcnQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDk5DO+FTpgh2aHp0PkUkfb6ZWT/gp0FBf/8ju4QWLFn7/e9oL944qg0ZTxXsGrDjVaIXHzV+jgIzLWWmsc/XT5b8KazNM9AQYQn2P0N2LO+67qGcClPo/HsLWo+NTy0CI+wgP6W6vFVjtjRAWkqYclENm/Ilf4Mebv+/Tkw27k5TGUtM/dtPNFMSVFED/Odd8I3FSwltnt3LZr9mw3WboXMdMKbjfagPu0+Hof8fmfzw6/whpB2RPzygPoM3CrEWsrOoQzCfmdeWTl1OXjKUyVQnNQ1runY6hT17du+1iRDMYfrPL9GIRUttMSIrv9+tIZGomRe5PyKEhLK8oGCBUnAgMBAAGjTjBMMEoGA1UdAQRDMEGAEIopGupTGfIz28Dyv9DbWE+hGzAZMRcwFQYDVQQDEw5BUk1QMlNSb290Q2VydIIQtAxj12p7aYVGXjyfs+CKaDAJBgUrDgMCHQUAA4IBAQAS6J6X6AmVdmR7ihxJrfkSPJDSq7wRip8/I/p5LKKlUjJPQ57FkdCqlejSXbzP3p+dWu1k6l7pBhnZU21FumegHuKeYnPgnlqZ+rXmfCuM6DWOSEi3joztqOUXFMPWbp0T4WnMOFO1QPR3IORHIxFVh5dHc6cikEf6KXbrywQ7o1Q3TZ4dg/taRL74FbXmkd/TuUPc/hUXDGk8vm4gE4YoZ4Za2tD1O1/qSm3JLzBZ12WM6kK17+vwrVGbiSLlp0WpV3Fy3FUsTXLomSR8Ouv4K84Y5Xnn7P5AA9Onu9l/ztcqJhopzZkBO0P4sSw64SCaVOXJ8NGszOEmEIuYrTDO"
$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $MyP2SRootCertPubKeyBase64

#Add VPN gateway - errored out for unknown reasons, had to do through portal
New-AzureRmVirtualNetworkGateway -Name $GWName -ResourceGroupName $RG -Location $Location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert

