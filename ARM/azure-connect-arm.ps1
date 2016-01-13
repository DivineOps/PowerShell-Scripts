#Open prompt to login into Azure account
Login-AzureRmAccount 

#Select MSDN subscription as current subscription
Get-AzureRmSubscription -SubscriptionName "Visual Studio Enterprise with MSDN" | Select-AzureRmSubscription

#See current selected context (subscription, tenant, etc.)
Get-AzureRmContext
