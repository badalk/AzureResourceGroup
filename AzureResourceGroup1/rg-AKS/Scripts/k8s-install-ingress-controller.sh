#!/bin/bash
aksResourceGroup=$1
aksName=$2
ingressDNSName=$3

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

echo "${nodeResourceGroup}"
echo "creating a public ip for ingress controller"
az network public-ip create --resource-group "${nodeResourceGroup}" --name aksIngressPublicIP --dns-name "${ingressDNSName}" --allocation-method static

if [ "$?" = "0" ]; then
	echo "getting newly created public ip for ingress controller"
	ingressPublicIp="$(az network public-ip show -g ${nodeResourceGroup} -n aksIngressPublicIP --query ipAddress -o tsv)"
	echo "Ingress public ip ${ingressPublicIp}"
else
	error_exit "$LINENO: Cannot create public ip in node resource group ${nodeResourceGroup} for aks given resource group ${aksResourceGroup} and cluster name ${aksName}" 1>&2
fi

if [ "$?" = "0" ]; then
	echo "Installing ingress service with public Ip ${ingressPublicIp} ......"
	helm install stable/nginx-ingress --namespace kube-system --set controller.service.loadBalancerIP="${ingressPublicIp}" --wait
	echo "Ingress controller is now installed."
else
	error_exit "$LINENO: Cannot install ingress service on ${aksName}" 1>&2
fi
