
#!/bin/bash

set -e # stop on errors
set -x # print commands when they are executed

aksResourceGroup=$1
aksName=$2
keyVaultResourceId=$3

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

echo "Creating AzureIdentity resources"
MY_PATH="`dirname \"$0\"`"              # relative
echo "$MY_PATH"

echo "Creating tiller service account and rolebinding ......."
#since we have RBAC enabled on the cluster we have to use rbac enabled deployment definition,
#but instead of reading it from github as commented in below comment we are using the locally defined yaml file which is 
#kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
kubectl create -f "$MY_PATH/../Resources/deployment-rbac.yaml"

#get node resource group for aks service
nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

# create managed service identity and get the client id
## TODO: we need to check if we will be pre-creating the msi and just using its client id and principalid or for each cluster we need to create a new msi
KV_NAME="k8s-msi"
clientId="$(az identity create -g ${nodeResourceGroup} -n ${KV_NAME} --query clientId -o tsv)"
Id="$(az identity show -g ${nodeResourceGroup} -n k8s-msi --query id -o tsv)"
principalId="$(az identity show -g ${nodeResourceGroup} -n k8s-msi --query principalId -o tsv)"

echo "MSI Client ID: ${clientId}, Id: ${Id}, principalId: ${principalId}"

# Assign Reader Role to new Identity for your keyvault
az role assignment create --role Reader --assignee ${principalId} --scope ${keyVaultResourceId}

# set policy to access keys in your keyvault
az keyvault set-policy -n ${KV_NAME} --key-permissions get --spn ${clientId}
# set policy to access secrets in your keyvault
az keyvault set-policy -n ${KV_NAME} --secret-permissions get --spn ${clientId}
# set policy to access certs in your keyvault
az keyvault set-policy -n ${KV_NAME} --certificate-permissions get --spn ${clientId}

