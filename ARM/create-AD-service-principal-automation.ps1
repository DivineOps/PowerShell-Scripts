# WARNING: CHANGE THE FOLLOWING PARAMETER VALUES PRIOR TO EXECUTING SCRIPT
$name = '{Name of Cert}'
$applicationName = '{Name of Azure AD Application}'
$resourceGroup = '{Name of Existing or New Resource Group'

# 1.Sign in to your account.
Write-Output "BEGIN STEP 1"
###########################################
# Connect to Azure
###########################################
#region - Connect to Azure subscription
Write-Host "`nConnecting to your Azure subscription ..." -ForegroundColor Green
try{$account = Get-AzureRmContext}
catch{$account = Login-AzureRmAccount}
#endregion

# 2.Create the Certificate
Write-Output "BEGIN STEP 2"
<#
    NOTE: for the certificate to be found by the Login-AzureRmAccount cmdlet, it must be in CurrentUser\My
#>
$thumbprint = (New-SelfSignedCertificate -DnsName "$name" -CertStoreLocation Cert:\CurrentUser\My -KeySpec KeyExchange).Thumbprint
$cert = (Get-ChildItem -Path cert:\CurrentUser\My\$thumbprint)
mkdir "C:\${name}"
Export-Certificate -Cert $cert -FilePath "C:\${name}\${name}.cer" -Type CERT
$password = Read-Host -Prompt "Enter a password for the new .pfx certificate:" -AsSecureString
if ($password -eq $null) {
    throw "You must enter a password so the .pfx can be created"
}
Export-PfxCertificate -Cert $cert -FilePath "C:\${name}\${name}.pfx" -Password $password 

# 3. create an X509Certificate object from your certificate and retrieve the key value. 
Write-Output "BEGIN STEP 3"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("C:\${name}\${name}.pfx", $password)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

# 4. Create an application in the directory with key values.
Write-Output "BEGIN STEP 4"
$azureAdApplication = New-AzureRmADApplication -DisplayName "${applicationName}" -HomePage "https://${applicationName}" -IdentifierUris "https://${applicationName}" `
    -KeyValue $keyValue -KeyType AsymmetricX509Cert

# 5.Create a service principal 
Write-Output "BEGIN STEP 5"
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId
Write-Output $servicePrincipal.Id


# EXECUTE STEP 6 SEPARATELY. FOR SOME REASON WHEN EXECUTED IN ONE SEQUENCE STEP 6 FAILS

# 6. Grant the Service Principal role
Write-Output "BEGIN STEP 6"
#New-AzureRmRoleAssignment -ObjectId $servicePrincipal.Id -ResourceGroupName $resourceGroup -RoleDefinitionName Owner
New-AzureRmRoleAssignment -ObjectId $servicePrincipal.Id -Scope "/subscriptions/45f7e5d7-593c-47c4-989c-d4745c4a175c" -RoleDefinitionName Owner

<#
# OPTIONAL
# 7.Log in to Azure using ServicePrincipal
#>
Write-Output "BEGIN STEP 7"
if ($account -eq $null) {
    $account = Login-AzureRmAccount
}
$tenantId = $account.Subscription.TenantId
Login-AzureRmAccount -ServicePrincipal -TenantId $tenantId -CertificateThumbprint $thumbprint -ApplicationId $azureAdApplication.ApplicationId


Write-Output "Done."