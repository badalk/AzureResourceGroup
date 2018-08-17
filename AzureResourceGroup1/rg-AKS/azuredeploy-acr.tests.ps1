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

	$boolVariable = $true

	context "Checking simple unit test" {
		it "checking if varible value is true" {
			$boolVariable | Should Be $true
		}
	}

}