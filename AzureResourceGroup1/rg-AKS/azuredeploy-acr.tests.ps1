﻿Param(
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
	Import-Module "${PSScriptRoot}\ConvertTo-SplattedHashtable.psm1"

	BeforeAll { #Enable DebugPreference to Continue to capture Debug info
		$DebugPreference = "Continue"

		#Login with Azure account
		$pwd = ConvertTo-SecureString $password -AsPlainText -Force
		$credential = New-Object System.Management.Automation.PSCredential($accountName, $pwd)
		Connect-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId $tenantId

		#Load Test Data
		##Load data based on the data file as per the convention
		#$TestDataFileName = $TestFileName.Replace("ps1", "Data.json") #Getting Tests Data file name (extension is json)
		#Write-Host "TestDataFileName: ${TestDataFileName}"
		#$TestDataFile = "${currentPath}\${TestDataFileName}"
		#Write-Host ("TestDataFile: " + $TestDataFile)
		#$ParameterSet = (Get-Content -Raw -Path $TestDataFile) | ConvertFrom-Json
	
		##convert PassedParameters to hashtable
		#$ht2 = @{}
		#$ParameterSet.psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }
		#$PassedParameters = $ht2.SyncRoot
		#Write-Host ("PassedParameters: " + $PassedParameters)
		$TestFileName = "azuredeploy-acr.Tests.ps1"
		#Getting ARM template file name (extension is json)
		$TemplateFileName = $TestFileName.Replace("Tests.ps1", "json") 
		$currentPath = $PSScriptRoot
		$TemplateFile = "${currentPath}\${TemplateFileName}"
		Write-Host ("TemplateFile: " + $TemplateFile)
		$TemplateParameterDefinitions = (get-content -Raw -Path $TemplateFile | ConvertFrom-Json).parameters
		$PassedParameters = {}

		$TestDataFileName = $TestFileName.Replace("ps1", "Data.json") #Getting Tests Data file name (extension is json)
		Write-Host "TestDataFileName: ${TestDataFileName}"
		$TestDataFile = "${currentPath}\${TestDataFileName}"
		Write-Host ("TestDataFile: " + $TestDataFile)
		$testcases = (Get-Content -Raw -Path $TestDataFile) | ConvertFrom-Json | ConvertTo-SplattedHashtable



	}


	Beforeeach {
		#Determine if we should skip replication test cases
		#$IsReplicationEnabled = ($PassedParameters.isReplicationEnabled) -and ($PassedParameters.sku -eq 'Premium')
		#$Skiptests = @{ 'Skip' = !$IsReplicationEnabled }
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

		it ("Container Registry location parameter <location> passed must be within allowed values") -TestCases $testcases {
			Param($location)
			$location | should -BeIn $TemplateParameterDefinitions.location.allowedValues
		}

		it  ("Container Registry Replication Location <replicatedregistrylocation> must be different than the provisioning location <location>") -TestCases $testcases {
			Param($location, $replicatedregistrylocation)
			#$IsReplicationEnabled = ($param.isReplicationEnabled) -and ($param.sku -eq 'Premium')
						
			$replicatedregistrylocation | should -Not -Be $location
		}

		it ("Container Registry Replication Location <replicatedregistrylocation> must be within allowed values")-TestCases $PassedParameters {
			Param($replicatedregistrylocation)
			$replicatedregistrylocation | should -BeIn $TemplateParameterDefinitions.replicatedregistrylocation.allowedValues
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

			It "Container Registry Service is deployed" {
				$param.validatedResources[0].type | should -Be "Microsoft.ContainerRegistry/registries"
			}

			It "Container Registry Replication is setup in a different location" {

			}
		}

		foreach ($param in $PassedParameters){
			UnitTest-AzureRmDeployment($param)
		}

	}



}