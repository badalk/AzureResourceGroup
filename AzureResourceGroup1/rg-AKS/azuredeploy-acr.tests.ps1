Param(
  [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
  #[string] [Parameter(Mandatory=$true)] $TemplateFile,
  #[hashtable] [Parameter(Mandatory=$true)] $PassedParameters
  [string] [Parameter(Mandatory=$true)] $accountName,
  [string] [Parameter(Mandatory=$true)] $password,
  [string] [Parameter(Mandatory=$true)] $tenantId


)

Describe "Azure Container Registry Deployment Tests" {
	# #################
	# ## Arrange ##
	# #################

	$TestFileName = "azuredeploy-acr.Tests.ps1"
	#Getting ARM template file name (extension is json)
	$TemplateFileName = $TestFileName.Replace("Tests.ps1", "json") 
	$currentPath = $PSScriptRoot
	$TemplateFile = "${currentPath}\${TemplateFileName}"
	Write-Host ("TemplateFile: " + $TemplateFile)
	$TemplateParameterDefinitions = (get-content -Raw -Path $TemplateFile | ConvertFrom-Json).parameters

	#Load Test Data
	#Load data based on the data file as per the convention
	$TestDataFileName = $TestFileName.Replace("ps1", "Data.json") #Getting Tests Data file name (extension is json)
	Write-Host "TestDataFileName: ${TestDataFileName}"
	$TestDataFile = "${currentPath}\${TestDataFileName}"
	Write-Host ("TestDataFile: " + $TestDataFile)
	$ParameterSet = (Get-Content -Raw -Path $TestDataFile) | ConvertFrom-Json
	
	#convert PassedParameters to hashtable
	$ht2 = @{}
	$ParameterSet.psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }
	$PassedParameters = $ht2.SyncRoot

	#Determine if we should skip replication test cases
	$IsReplicationEnabled = ($PassedParameters.isReplicationEnabled) -and ($PassedParameters.sku -eq 'Premium')
	$Skiptests = @{ 'Skip' = !$IsReplicationEnabled }

	BeforeAll { #Enable DebugPreference to Continue to capture Debug info
		$DebugPreference = "Continue"

		#Login with Azure account
		$pwd = ConvertTo-SecureString $password -AsPlainText -Force
		$credential = New-Object System.Management.Automation.PSCredential($accountName, $pwd)
		Connect-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId $tenantId

	}


	Beforeeach {

	}

	Aftereach{

	}

	AfterAll { #Reset Debug Preferences 
		$DebugPreference = "SilentlyContinue"
	}

	# #######################
	# ###### Assert #########
	# #######################

	#Context "When Azure Container Registry is deployed without parameters" {
	#	try {
	#		$output = Test-AzureRmResourceGroupDeployment `
	#				-ResourceGroupName $ResourceGroupName `
	#				-TemplateFile $TemplateFile `
	#				-TemplateParameterFile null `
	#				-ErrorAction Stop `
	#					5>&1
	#	}
	#	catch {
	#		$ex = $_.Exception | Format-List -Force
	#	}

	#	It "Should throw exception" {
	#		$ex | Should -Not -Be $null
	#		$ex.Message | Should -Not -Be ([string]::Empty)
	#	}
	#}

	Context "Check for Valid Parameter Values"  {

		it ("Container Registry location parameter passed must be within allowed values") -TestCases $PassedParameters {
			Param($param)
			$param.parameters.location | should -BeIn $TemplateParameterDefinitions.location.allowedValues
		}

		it @Skiptests ("Container Registry Replication Location parameter must be different than the provisioning location")-TestCases $PassedParameters {
			Param($param)
			$param.parameters.replicatedregistrylocation | should -Not -Be $param.parameters.location
		}

		it @Skiptests ("Container Registry Replication Location parameter must be within allowed values")-TestCases $PassedParameters {
			Param($param)
			$param.parameters.replicatedregistrylocation | should -BeIn $TemplateParameterDefinitions.replicatedregistrylocation.allowedValues
		}

	}

	Context "When Azure Container Registry (ACR) is deployed with valid parameters" { 
		#$PassedParameters = (get-content "$TemplateParameterFile" | ConvertFrom-Json -ErrorAction SilentlyContinue).parameters
		function UnitTest-AzureRmDeployment {
			param ($param)

			$output = Test-AzureRmResourceGroupDeployment `
					-ResourceGroupName $ResourceGroupName `
					-TemplateFile $TemplateFile `
					-TemplateParameterObject $param `
					-ErrorAction Stop `
						5>&1

			$responseItem = $output -like "*HTTP RESPONSE*"
			$httpresponse = ($responseItem -split "Body:")[1]
			$result = ($httpresponse | ConvertFrom-Json).properties

			It "ACR deployment should succeed" {
				$result.provisioningState | Should -Be "Succeeded"
			}

			It "If service tier is not premium - no registry relication irrespective of isReplicationEnabled is set to true or false" {
			
			}

			It "If service tier is premium then only allow replicated regions" {

			}
		}

		foreach ($param in $PassedParameters){
			UnitTest-AzureRmDeployment($param)
		}

	}



}