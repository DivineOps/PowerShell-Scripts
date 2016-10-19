# Migrate Users from Windows AD to Azure AD B2C
This PowerShell script will create users in Azure AD B2C (or standard Azure AD) based on a CSV file with user information exported from Windows AD (or any 3rd party directory) The users will be assigned a default password, which they will be required to change upon the first sign in. 

# Prerequisites
## Create Azure AD B2C Instance
Follow this guide:  
https://azure.microsoft.com/en-us/documentation/articles/active-directory-b2c-get-started/  
Note: This guide refers to the old Azure portal. By the time you are reading this document creating the tenant might be available in the new Azure portal. The created tenant is identical regardless. 
## Create a Global Admin in the B2C Tenant 
Note: this step is important because the user used to run the PowerShell script needs to belong to the new directory tenant domain, so the user you created the directory with won’t work.  
How-to for Old portal:  
Choose Active Directory in left pane -> Choose Active Directory Tenant -> Click Users -> Click Add on bottom panel -> Choose “New user in your organization” -> Create new username -> Create display name -> Choose Role “Global Admin -> Add alternate email address -> Click Create -> Note the email and the temporary password  
### Change new global admin password
The newly created user is required to change the password prior to performing any other actions. The simplest way is by singing in into Azure Portal.  
•	Open new In Private/Incognito browser window  
•	Navigate to https://manage.windowsazure.com  
•	Set up a new password when prompted  
•	Ignore the error about having no access to any Azure subscriptions – it is not relevant since all we needed is a password reset

## Install AAD PowerShell Module
Download and install the AAD PowerShell Module from here:  
http://connect.microsoft.com/site1164/Downloads/DownloadDetails.aspx?DownloadID=59185 

## Export Users from Windows AD
1.	Log into your Windows AD domain controller
2.	Open a PowerShell window with administrative permissions
3.	Run the following command to export all users
```
Get-ADUser -Filter * -SearchBase "ou=Ou,dc=contoso,dc=com" -Properties * | Export-Csv  "c:\users.csv"
```
Note: change the domain and ou to reflect the appropriate values.  
Another note: the generated spreadsheet might need some cleanup.  
The import script skips disabled accounts, which usually includes most of the default service accounts in the directory, however if you want to exclude specific users from the AAD import you should delete them from the CSV file.  
Last note: there is no need to delete any of the columns as the script will simply ignore anything that isn’t referenced.

 
# Running the PowerShell Script

## Set variables
Prior to running the script please set the following:
```
$defaultPassword
``` 
The password to be used when creating new users. The user will be prompted to change this password on first sign in.
```
$domainName
```
Your AAD B2C tenant domain name (such as contoso.onmicrosoft.com) or a custom domain, if assigned.  
Note that custom domain can be assigned after the migrations, and user emails will automatically update to the custom domain name. 
```
$usersCsvPath 
```
The full path to the CSV file with the user information that was exported from Windows AD.   

## Relevant User Properties
The script will iterate over all the users in the CSV for which account Enabled property is true, and add them to the Azure AD B2C tenant using the following command:
```
New-MsolUser -UserPrincipalName $upn -DisplayName $user.DisplayName -FirstName $user.GivenName -LastName $user.Surname -Password $defaultPassword 
```
So that only the following properties will be migrated:  
UPN (with the new domain extension)  
First Name  
Last Name  
Display Name  
If required, other properties present in the CSV (such as Address, Country, Title etc.) can be added to the command PRIOR to running the script
The full spec of the command can be found here:  
https://msdn.microsoft.com/en-us/library/azure/dn194096%28v=azure.98%29.aspx?f=255&MSPPError=-2147217396  

 
# Error Checking
The script will skip the user migration if the user with the same User Profile Name already exists in AAD  
The script will skip the user migration when the user account in Windows AD is disabled (skips most system accounts)   
# Limitations
The script does not currently migrate user groups.
