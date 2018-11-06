acrname=$1
k8sAdminGroupId=$5

az configure --defaults acr=${acrName}

az acr helm repo add

MY_PATH="`dirname \"$0\"`"              # relative
echo "$MY_PATH"

echo "Creating cluster admib rolebinding and azurepodidentity resource"

helm package 
#kubectl create -f "$MY_PATH/../Resources/cluster-admins.yaml"
helm install k8s-cluster-admin --set adminAADGoupId=${k8sAdminGroupId}