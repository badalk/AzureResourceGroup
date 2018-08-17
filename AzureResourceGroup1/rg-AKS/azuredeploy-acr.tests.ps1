Param(
  [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
  [string] [Parameter(Mandatory=$true)] $TemplateFile,
  [hashtable] [Parameter(Mandatory=$true)] $PassedParameters
)

Describe "Azure Container Registry Deployment Tests" {
	#Arrange
	#$PassedParameters = (get-content "$TemplateParameterFile" | ConvertFrom-Json -ErrorAction SilentlyContinue).parameters
	Write-Output $PassedParameters.location
	$TemplateParameters = (get-content "$TemplateFile" | ConvertFrom-Json -ErrorAction SilentlyContinue).parameters
	$IsReplicationEnabled = ($PassedParameters.isReplicationEnabled) -and ($PassedParameters.sku -eq 'Premium')
	$Skiptests = @{ 'Skip' = !$IsReplicationEnabled }

	BeforeAll { #Enable DebugPreference to Continue to capture Debug info
		$DebugPreference = "Continue"

		$accountName ="http://azure-cli-2018-08-09-15-12-39"
		$password = ConvertTo-SecureString "f1c35295-8e9a-4f7c-a753-57b9d15dc70e" -AsPlainText -Force
		$credential = New-Object System.Management.Automation.PSCredential($accountName, $password)
		Connect-AzureRmAccount -ServicePrincipal -Credential $credential -TenantId "b25fcb44-9c49-413c-9fdc-b59b39447b84"

	}


	Beforeeach {

	}

	Aftereach{

	}

	AfterAll { #Reset Debug Preferences 
		$DebugPreference = "SilentlyContinue"
	}

	#Assert
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

		it ("Container Registry location parameter passed must be within allowed values"){
			$PassedParameters.location | should -BeIn $TemplateParameters.location.allowedValues
		}

		Context "Container Registry Replication Parameters Tests" {
			it @Skiptests ("Container Registry Replication Location parameter must be different than the provisioning location"){
				$PassedParameters.replicatedregistrylocation | should -Not -Be $PassedParameters.location.value
			}

			it @Skiptests ("Container Registry Replication Location parameter must be within allowed values"){
				$PassedParameters.replicatedregistrylocation | should -BeIn $TemplateParameters.replicatedregistrylocation.allowedValues
			}
		}

	}

	Context "When Azure Container Registry (ACR) is deployed with valid parameters" { 
		#$PassedParameters = (get-content "$TemplateParameterFile" | ConvertFrom-Json -ErrorAction SilentlyContinue).parameters

		$output = Test-AzureRmResourceGroupDeployment `
				-ResourceGroupName $ResourceGroupName `
				-TemplateFile $TemplateFile `
				-TemplateParameterObject $PassedParameters `
				-ErrorAction Stop `
					5>&1

		$responseItem = $output -like "*HTTP RESPONSE*"
		#Write-Output $responseItem

		$httpresponse = ($responseItem -split "Body:")[1]
		Write-Output $httpresponse

		$result = ($httpresponse | ConvertFrom-Json).properties

		It "ACR deployment should succeed" {
			$result.provisioningState | Should -Be "Succeeded"
		}

		It "If service tier is not premium - no registry relication irrespective of isReplicationEnabled is set to true or false" {
			
		}

		It "If service tier is premium then only allow replicated regions" {

		}
	}



}