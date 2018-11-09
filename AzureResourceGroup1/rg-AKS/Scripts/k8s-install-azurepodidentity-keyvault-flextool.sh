set -o xtrace

aksResourceGroup=$1
aksName=$2
acrname=$3
keyVaultResourceId=$4
azurePodIdentityResourceId=$5

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

#get node resource group for aks service
echo "\$aksResourceGroup: ${aksResourceGroup}"
echo "\$aksName: ${aksName}"
nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

echo "Creating AzureIdentity resources"
MY_PATH="`dirname \"$0\"`"              # relative
echo "$MY_PATH"

echo "Creating aadpodidentity resources ......."
#since we have RBAC enabled on the cluster we have to use rbac enabled deployment definition,
#but instead of reading it from github as commented in below comment we are using the locally defined yaml file which is 
#kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
#kubectl delete -f "$MY_PATH/../Resources/deployment-rbac.yaml" 
kubectl create -f "$MY_PATH/../Resources/deployment-rbac.yaml" 


##############################################################################################################################
# All of this below can be pre-created (MSI, Granting MSI permission to the key vault to read secrets, certificates and keys)
# If not, uncomment and service principal should have permission to read and write directory data, which may be difficult
##############################################################################################################################

# echo "AKS Node Resource Group (\$nodeResourceGroup): '${nodeResourceGroup}'"
# # create managed service identity and get the client id
# ## TODO: we need to check if we will be pre-creating the msi and just using its client id and principalid or for each cluster we need to create a new msi
# echo "Creating an msi to access key vault...."
# clientId="$(az identity create -g ${nodeResourceGroup} -n ${azurePodIdentityName} --query clientId -o tsv)"
# echo "MSI Client Id: ${clientId}"
# Id="$(az identity show -g ${nodeResourceGroup} -n ${azurePodIdentityName} --query id -o tsv)"
# echo "MSI Resorce Id: ${Id}"
# principalId="$(az identity show -g ${nodeResourceGroup} -n ${azurePodIdentityName} --query principalId -o tsv)"
# echo "MSI Principal Id: ${principalId}"

# echo "MSI Client ID: ${clientId}, Id: ${Id}, principalId: ${principalId}"

# # Assign Reader Role to new Identity for your keyvault
# az role assignment create --role Reader --assignee ${principalId} --scope ${keyVaultResourceId}

# KV_NAME="aks-sp-key-secret-vault" #TODO: get it from keyvault resoure ID parameter
# # set policy to access keys in your keyvault
# az keyvault set-policy -n ${KV_NAME} --key-permissions get --spn ${clientId}
# # set policy to access secrets in your keyvault
# az keyvault set-policy -n ${KV_NAME} --secret-permissions get --spn ${clientId}
# # set policy to access certs in your keyvault
# az keyvault set-policy -n ${KV_NAME} --certificate-permissions get --spn ${clientId}

######################################################################################
# 
######################################################################################
echo "Creating an msi to access key vault...."
clientId="$(az identity show --ids ${azurePodIdentityResourceId} --query clientId -o tsv)"
echo "MSI Client Id: ${clientId}"
principalId="$(az identity show ${azurePodIdentityResourceId} --query principalId -o tsv)"
echo "MSI Principal Id: ${principalId}"

#package and add aadpodidentity helm chart to ACR repository, TODO: if does not exist
az configure --defaults acr=${acrname}
az acr helm repo add
#cd "$MY_PATH/../Resources/"
helm package "$MY_PATH/../Resources/aadpodidentity" --destination "$MY_PATH/../Resources""
az acr helm push "$MY_PATH/../Resources/adpodidentity-1.0.0.tgz"

helm install aadpodidentity --set name=${azurePodIdentityName} --set msi.resourceID=${keyVaultResourceId} --set msi.clientID=${clientId}
