
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
#since we have RBAC enabled on the cluster we have to use rbac enabled deployment definition
kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml

#get node resource group for aks service
nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

#create managed service identity and get the client id
clientId="$(az identity create -g ${nodeResourceGroup} -n k8s-msi --query clientId -o tsv)"
Id="$(az identity show -g ${nodeResourceGroup} -n k8s-msi --query id -o tsv)"
principalId="$(az identity show -g ${nodeResourceGroup} -n k8s-msi --query principalId -o tsv)"

# Assign Reader Role to new Identity for your keyvault
az role assignment create --role Reader --assignee ${principalId} --scope ${keyVaultResourceId}

# set policy to access keys in your keyvault
az keyvault set-policy -n $KV_NAME --key-permissions get --spn ${clientId}
# set policy to access secrets in your keyvault
az keyvault set-policy -n $KV_NAME --secret-permissions get --spn ${clientId}
# set policy to access certs in your keyvault
az keyvault set-policy -n $KV_NAME --certificate-permissions get --spn ${clientId}

