aksResourceGroup=$1
aksName=$2

nodeResourceGroup="$(az aks show --resource-group ${aksResourceGroup} --name ${aksName} --query nodeResourceGroup -o tsv)"

echo "${nodeResourceGroup}"

echo "creating a public ip for ingress controller"
az network public-ip create --resource-group "${nodeResourceGroup}" --name aksIngressPublicIP --allocation-method static

echo "getting newly created public ip for ingress controller"
ingressPublicIp="$(az network public-ip show -g ${nodeResourceGroup} -n aksIngressPublicIP --query ipAddress -o tsv)"

echo "Ingress public ip ${ingressPublicIp}"

echo "Install helm client ......."
snap install helm --classic

echo "Creating tiller service account and rolebinding ......."
kubectl create -f /../Resources/helm-rbac.yaml

echo "Copying Kube context into helm ......."
cp -i ~/.kube/config ~/snap/helm/common/kube/

echo "Install Tiller service and initialize helm ......."
helm init --service-account tiller

echo "Install ingress service with poblic Ip ${ingressPublicIp}"
helm install stable/nginx-ingress --namespace kube-system --set controller.service.loadBalancerIP="${ingressPublicIp}"