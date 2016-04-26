$deployName="asatestdeploy"
$RGName="testasa"
$locName="East US"
$templateFile="C:\Work\Repos\PowerShell-Scripts\ARM\Templates\asa-template.json"
$templateParameterFile="C:\Work\Repos\PowerShell-Scripts\ARM\Templates\asa-parameters.json"
New-AzureRmResourceGroup –Name $RGName –Location $locName
New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile