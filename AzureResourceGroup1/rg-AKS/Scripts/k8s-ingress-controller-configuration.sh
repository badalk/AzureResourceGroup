aksResourceGroup=$1
aksName=$2

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

echo "${nodeResourceGroup}"
echo "creating a public ip for ingress controller"
az network public-ip create --resource-group "${nodeResourceGroup}" --name aksIngressPublicIP --allocation-method static

if [ "$?" = "0" ]; then
	echo "getting newly created public ip for ingress controller"
	ingressPublicIp="$(az network public-ip show -g ${nodeResourceGroup} -n aksIngressPublicIP --query ipAddress -o tsv)"

	echo "Ingress public ip ${ingressPublicIp}"
else
	echo "Error Occured:"
	error_exit "$LINENO: Cannot create public ip in node resource group ${nodeResourceGroup} for aks given resource group ${aksResourceGroup} and cluster name ${aksName}" 1>&2
fi

echo "Install helm client ......."
sudo snap install helm --classic

MY_PATH="`dirname \"$0\"`"              # relative
echo "$MY_PATH"

echo "Creating tiller service account and rolebinding ......."
kubectl create -f "$MY_PATH/../Resources/helm-rbac.yaml"

echo "Copying Kube context into helm ......."
mkdir ~/snap/helm/common/kube
cp -f ~/.kube/config ~/snap/helm/common/kube/

echo "Install Tiller service and initialize helm ......."
helm init --service-account tiller

echo "Install ingress service with public Ip ${ingressPublicIp}"
helm install stable/nginx-ingress --namespace kube-system --set controller.service.loadBalancerIP="${ingressPublicIp}"