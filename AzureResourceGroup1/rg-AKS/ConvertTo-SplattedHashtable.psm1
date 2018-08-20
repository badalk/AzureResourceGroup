#
# ConvertTo_SplattedHashtable.psm1
#
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

Export-ModuleMember -Function 'ConvertTo-SplattedHashtable'
