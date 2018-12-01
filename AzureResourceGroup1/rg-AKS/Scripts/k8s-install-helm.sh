#!/bin/bash
echo "Install helm client ......."
sudo snap install helm --classic

MY_PATH="`dirname \"$0\"`"              # current directory path
echo "$MY_PATH"

echo "Creating tiller service account and rolebinding ......."
kubectl create -f "$MY_PATH/../Resources/helm-rbac.yaml"

echo "Create helm kube config folder if one does not exist"
if [ ! -d "${HOME}/snap/helm/common/kube" ] 
then
	mkdir "${HOME}/snap/helm/common/kube"
else
	rm "${HOME}/snap/helm/common/kube/config"	#remove config file if one exists already as it may be from previous deployment
fi

echo "Copying Kube context into helm ......."
cp -f /var/lib/jenkins/.kube/config ~/snap/helm/common/kube/ 

echo "Install Tiller service and initialize helm. Wait until tiller pods are ready ......."
helm init --wait --service-account tiller

