aksResourceGroup=$1
aksName=$2

nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

echo "${nodeResourceGroup}"

az network public-ip create --resource-group "${nodeResourceGroup}" --name aksIngressPublicIP --allocation-method static

ingressPublicIp="$(az network public-ip show --resource-group ${nodeResourceGroup} --name aksIngressPublicIP)"
 
echo "ingress public ip ${ingressPublicIp}"