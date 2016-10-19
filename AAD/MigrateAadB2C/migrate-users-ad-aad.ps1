# Prerequisits:

# Download the AAD PowerShell Module from here:
# http://connect.microsoft.com/site1164/Downloads/DownloadDetails.aspx?DownloadID=59185

# Export users from Windows AD (run in PowerShell on Windows AD DC)
# Specify the correct domain and organizational unit
# Note: some cleanup of the CSV might be needed if not all accounts need to be migrated
# Get-ADUser -Filter * -SearchBase "ou=Ou,dc=contoso,dc=com" -Properties * | Export-Csv  "c:\users.csv"

# Sign In to the Azure AD
# Important: the user needs to be a global administrator in the AAD, and belong to the AAD domain (or the custom domain that has been assigned)! 
# For instance johndoe@contoso.onmicrosoft.com and NOT johndoe@contoso.com
$msolcred = get-credential
connect-msolservice -credential $msolcred

# Important: Set variables!
# Default password that will be assigned to all new users created in AAD
$defaultPassword = "changeme@123"
# AAD domain name
$domainName = "sashademob2c.onmicrosoft.com"
# Pass to the CSV with users exported from Windows AD
$usersCsvPath = "C:\Work\Repos\PowerShell-Scripts\AAD\users.csv"


# Import the csv with users data exported from Windows AD
# Specify path to eported file
$users = Import-Csv $usersCsvPath


Write-Output "`nList of users to be migrated from Windows AD"
Write-Output "----------------------------------------------------------------`n"
# Iterate over all users
foreach($user in $users){   

	#Skip disabled accounts
	if($user.Enabled -eq "True") {
		Write-Output ([string]::Format("Name: {0}, UPN: {1}", $user.DisplayName, $user.UserPrincipalName)) 
	}
}
Write-Output "----------------------------------------------------------------`n`n" 

Write-Output ([string]::Format("Migrating users to AAD domain {0}", $domainName))
Write-Output "----------------------------------------------------------------`n`n"


# Migrate

Write-Output "Adding all users from Windows AD to AAD"
Write-Output "----------------------------------------------------------------`n`n"
# Iterate over all users
foreach($user in $users){   

	#Skip disabled accounts
	if($user.Enabled -eq "True") {
		# Construct the new User Principal Name for AAD
		$upn = ([string]::Format("{0}@{1}", $user.SamAccountName, $domainName))
		
		# Check if user exists in AAD (error action - none)
		$exists = Get-MsolUser -UserPrincipalName $upn -ea 0
		
		if(!$exists.UserPrincipalName) { 
			Write-Output ([string]::Format("Adding user {0}, UPN {1}`n", $user.DisplayName, $upn))
			# All possible parameeters for New-MSolUser outlined here
			# https://msdn.microsoft.com/en-us/library/azure/dn194096%28v=azure.98%29.aspx?f=255&MSPPError=-2147217396
			New-MsolUser -UserPrincipalName $upn -DisplayName $user.DisplayName -FirstName $user.GivenName -LastName $user.Surname -Password $defaultPassword
			
		} else { 
		
			Write-Output ([string]::Format("The user with UPN {0} already exists, skipping user creation`n", $upn))
		}
	}
}

# List all AAD users
Write-Output "`nListing all users in AAD"
Write-Output "----------------------------------------------------------------`n"
Get-MsolUser -All
Write-Output "----------------------------------------------------------------`n`n"


