#opens a sign in prompt in the default browser and downloads publishsettings file
#Get-AzurePublishSettingsFile

#Import publish settings from saved location (~connect to account)
#Import-AzurePublishSettingsFile c:\location\filename.publishsettings

#Select subscription
#Select-AzureSubscription -SubscriptionName "Visual Studio Enterprise with MSDN"

#Option 2?

#Connect to azure account
Add-AzureAccount

#Select subscription
Select-AzureSubscription -SubscriptionName "Visual Studio Enterprise with MSDN"
