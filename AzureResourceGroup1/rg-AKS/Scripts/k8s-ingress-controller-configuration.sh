aksResourceGroup=$1
aksName=$2

nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

echo "${nodeResourceGroup}"

echo "creating a public ip for ingress controller"
az network public-ip create --resource-group "${nodeResourceGroup}" --name aksIngressPublicIP --allocation-method static

echo "getting newly created public ip for ingress controller"
ingressPublicIp="$(az network public-ip show -g ${nodeResourceGroup} -n aksIngressPublicIP --query \"{address: ipAddress}\")"
 
echo "ingress public ip ${ingressPublicIp}"