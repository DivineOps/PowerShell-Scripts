$deployName="xxx"
$RGName="yyy"
$locName="zzz"

$templateFile="local path to template"
$templateParameterFile="local path to params"

New-AzureRmResourceGroup –Name $RGName –Location $locName
New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile