-e # stop on errors
-x # print commands when they are executed

echo "Install helm client ......."
sudo snap install helm --classic		#need to find out how to avoid this without using sudo

MY_PATH="`dirname \"$0\"`"              # relative
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

echo "Install Tiller service and initialize helm ......."
helm init --service-account tiller