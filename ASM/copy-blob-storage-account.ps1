=======================

# Copy data from one storage account to another.

# Source storage account context, container and blob to copy
$SrcCtx = New-AzureStorageContext -StorageAccountName "SrcStorageAccount" -StorageAccountKey "<Source Storage Key>"
$srcContainer = "srccontainer"
$srcBlob = "testfile"

# Destination storage account context, container and blob
$DstCtx = New-AzureStorageContext -StorageAccountName "DestStorageAccount" -StorageAccountKey "<Destination Storage Key>"
$DstContainer = "dstcontainer"
$DstBlob = "testfile"

# give the copy time some time (arbitrarily chose 5 days) before the SAS URL expires
$ExpTime = (Get-Date).AddDays(5) 
# SAS Url with read only permission
$SrcSASURI = New-AzureStorageBlobSASToken -Context $SrcCtx -Container $srcContainer -Blob $srcBlob -FullUri -ExpiryTime $ExpTime -Permission "r" 

# Kick off a background copy job
Start-AzureStorageBlobCopy -AbsoluteURI $SrcSASURI -DestContext $DstCtx -DestContainer $DstContainer -DestBlob $DstBlob -Verbose -Force 

# Check the copy job status
Get-AzureStorageBlobCopyState -Context $DstCtx -Container $DstContainer -Blob $DstBlob -Verbose 

