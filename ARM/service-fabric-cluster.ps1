#Connect to cluster
Connect-serviceFabricCluster -ConnectionEndpoint sasha-sf-cluster.eastus.cloudapp.azure.com:19000 -KeepAliveIntervalInSec 10

#Copy the package to the cluster that you connected to previously.
$applicationPath = "C:\Work\Projects\ServiceFabricDemo\ServiceFabricDemo\pkg\Debug"
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $applicationPath -ApplicationPackagePathInImageStore "ServiceFabricDemo" -ImageStoreConnectionString fabric:ImageStore

#Register your application type with Service Fabric
Register-ServiceFabricApplicationType -ApplicationPathInImageStore "ServiceFabricDemo"

#Create a new instance on the application type that you just registered
New-ServiceFabricApplication -ApplicationName fabric:/ServiceFabricDemo -ApplicationTypeName ServiceFabricDemoType -ApplicationTypeVersion 1.0.0



$rgName = "ServiceFabricDemo" 
$vmssName = "Web"

#Control VMSS
Start-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $vmssName
Stop-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $vmssName

Get-AzureRmVmss -ResourceGroupName $rgName -VMScaleSetName $vmssName

$connEndpoint = "sasha-sf-demo.centralus.cloudapp.azure.com:19000"

#Connect to cluster
Connect-serviceFabricCluster -ConnectionEndpoint $connEndpoint -KeepAliveIntervalInSec 10

#Copy the package to the cluster that you connected to previously.
$applicationPath = "C:\Work\Repos\SF\Actors\VisualObjects\VisualObjects\pkg\Debug"
#Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $applicationPath -ApplicationPackagePathInImageStore "VisualObjects.ActorServicePkg" -ImageStoreConnectionString fabric:ImageStore

#Copy-ServiceFabricApplicationPackage -ApplicationPackagePath MyApplicationType -ImageStoreConnectionString (Get-ImageStoreConnectionStringFromClusterManifest(Get-ServiceFabricClusterManifest))

Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $applicationPath -ImageStoreConnectionString fabric:ImageStore


#Register your application type with Service Fabric
#Register-ServiceFabricApplicationType -ApplicationPathInImageStore "VisualObjects.ActorServicePkg"
Register-ServiceFabricApplicationType VisualObjectsApplicationType

#Create a new instance on the application type that you just registered
#New-ServiceFabricApplication -ApplicationName fabric:/VisualObjects.ActorServicePkg -ApplicationTypeName VisualObjectsApplicationType -ApplicationTypeVersion 1.0.0
New-ServiceFabricApplication -ApplicationName fabric:/VisualObjects -ApplicationTypeName VisualObjectsApplicationType -ApplicationTypeVersion 1.0.0


