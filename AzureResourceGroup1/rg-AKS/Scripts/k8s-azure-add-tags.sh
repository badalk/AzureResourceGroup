set -o xtrace

aksResourceGroup=$1
aksName=$2

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

#Get tags from aks resource group
echo "Getting aks resource group tags"
jsonrgtags=$(az group show -g ${aksResourceGroup} --query tags)
rgtags=$(echo $jsonrgtags | tr -d '"{},' | sed 's/: /=/g')

echo "AKS resource group tags : $rt"

echo "Get AKS node resource group"
nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

# Get existing tags on AKS node resource group as we do not want to erase existing tags which are important for AKS to function
jsonnodergtags=$(az group show -g ${nodeResourceGroup} --query tags)
nodergtags=$(echo $jsonrtag | tr -d '"{},' | sed 's/: /=/g')

echo "Updating tags on AKS node resource Group"
az group update --tags $rgtags $nodergtags -g $nodeResourceGroup 