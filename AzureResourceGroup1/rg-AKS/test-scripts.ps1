$ResourceGroupName = "rg-aks-arm-cicd"
$TemplateFile = "C:\MyWork\Azure\ARM\ARM-FirstSample\AzureResourceGroup1\AzureResourceGroup1\rg-AKS\azuredeploy-aks.json"
$TemplateParametersFile = "C:\MyWork\Azure\ARM\ARM-FirstSample\AzureResourceGroup1\AzureResourceGroup1\rg-AKS\azuredeploy-aks-cicd.parameters.json"

New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                   -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterFile $TemplateParametersFile `
                                   -Mode Incremental `
                                   -Force -Verbose `
                                   -ErrorVariable ErrorMessages