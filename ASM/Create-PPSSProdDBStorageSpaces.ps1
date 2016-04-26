### NEED TO UPDATE FOR NEW STORAGE POOLS ###

# Create the storage pool and virtual disks for the Prod DB server
$storagePoolName = 'SQLDataPool'
$virtualDiskName = 'SQLDataDisk'
$interleaveSize = 65536
$allocationUnitSize = 65536
$sleepTime = 30
$dataDisks = Get-PhysicalDisk -CanPool $True
$diskCount = $dataDisks.Count
$storagePool = New-StoragePool -FriendlyName $storagePoolName -StorageSubsystemFriendlyName "Storage Spaces*" -PhysicalDisks $dataDisks
$disk = New-VirtualDisk -StoragePoolFriendlyName $storagePoolName -FriendlyName $virtualDiskName -UseMaximumSize -NumberOfColumns $diskCount -ResiliencySettingName Simple -Interleave $interleaveSize | `
    Initialize-Disk -Confirm:$False -PassThru -PartitionStyle GPT
$disk | New-Partition -DriveLetter E -Size 100GB
sleep -Seconds $sleepTime
Format-Volume -DriveLetter E -NewFileSystemLabel 'Installation' -FileSystem NTFS -AllocationUnitSize $allocationUnitSize -Confirm:$False
$disk | New-Partition -DriveLetter G -Size 400GB
sleep -Seconds $sleepTime
Format-Volume -DriveLetter G -NewFileSystemLabel '' -FileSystem NTFS -AllocationUnitSize $allocationUnitSize -Confirm:$False
$disk | New-Partition -DriveLetter K -Size 2500GB
sleep -Seconds $sleepTime
Format-Volume -DriveLetter K -NewFileSystemLabel 'Backups' -FileSystem NTFS -AllocationUnitSize $allocationUnitSize -Confirm:$False
$disk | New-Partition -DriveLetter L -Size 400GB
sleep -Seconds $sleepTime
Format-Volume -DriveLetter L -NewFileSystemLabel 'Database Logs' -FileSystem NTFS -AllocationUnitSize $allocationUnitSize -Confirm:$False
$disk | New-Partition -DriveLetter M -Size 2900GB
sleep -Seconds $sleepTime
Format-Volume -DriveLetter M -NewFileSystemLabel 'Databases' -FileSystem NTFS -AllocationUnitSize $allocationUnitSize -Confirm:$False
$disk | New-Partition -DriveLetter T -Size 400GB
sleep -Seconds $sleepTime
Format-Volume -DriveLetter T -NewFileSystemLabel 'TempDB' -FileSystem NTFS -AllocationUnitSize $allocationUnitSize -Confirm:$False

# Some helpful cmdlets to run as needed
<#
Get-StoragePool
Get-StoragePool -FriendlyName $storagePoolName
Remove-StoragePool -FriendlyName $storagePoolName
Get-VirtualDisk
Get-VirtualDisk -FriendlyName $virtualDiskName
Remove-VirtualDisk -FriendlyName $virtualDiskName
#>

