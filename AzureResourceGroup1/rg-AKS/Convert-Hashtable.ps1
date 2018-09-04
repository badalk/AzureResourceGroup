
function ConvertTo-SplattedHashtable {
    [CmdletBinding()]
    [OutputType('hashtable')]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
 
    process {

        $testcases = @()
        foreach($param in $InputObject){

            $theObject = $param.parameters.psObject.Properties 

            Write-Host ("theObject:" + $theObject)
            $ht2 = @{}

            foreach($object in $theObject)
            {
                $ht2[$object.Name] = $object.Value.value
            }

            Write-Host("ht2 = " + $ht2.psobject.properties)
            $testcases += $ht2
       }

       $testcases
    }
}



describe a {
   $TestsDataFile = "C:\MyWork\Azure\ARM\ARM-FirstSample\AzureResourceGroup1\AzureResourceGroup1\rg-AKS\azuredeploy-acr.Tests.Data.json"
   $testcases = (Get-Content -Raw -Path $TestsDataFile) | ConvertFrom-Json | ConvertTo-SplattedHashtable
   Write-Host("testcases : " + $testcases.Keys)

       it "RegistryLocation : <replicatedregistrylocation> should be differen than replicationLocation : <location> " -TestCases $testcases {
        param ( $location, $replicatedregistrylocation )
        Write-Host("parameters : " + $location + ", " + $replicatedregistrylocation)
        $location | should -Not -Be $replicatedregistrylocation
    }

}