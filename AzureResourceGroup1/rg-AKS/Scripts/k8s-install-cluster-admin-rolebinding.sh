acrName=$1
k8sAdminGroupId=$2

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

az configure --defaults acr=${acrName}

az acr helm repo add

MY_PATH="`dirname \"$0\"`"              # relative
echo "$MY_PATH"

#package and add aadpodidentity helm chart to ACR repository, TODO: if does not exist
az configure --defaults acr=${acrName}
echo "Adding helm repo for ACR...."
az acr helm repo add

###############################################################################################
# All of this below can be pre-created and helm chart can be pre-published to ACR
###############################################################################################

echo "Creating cluster admib rolebinding"

echo "Packaging cluster admin role helm chart ...."
helm package "$MY_PATH/../Resources/k8sClusterAdmin" --destination "$MY_PATH/../Resources"
echo "Pushing helm chart to ACR ..."
#az login --service-principal -u "a03158e9-58f5-4e5e-b11b-b5a2df77c661" -p "FiS+yQNCI7GrX4jJ5ydyZOH9XmbCFCSBN70SdiwwtWg=" --tenant "b25fcb44-9c49-413c-9fdc-b59b39447b84"
az acr helm push -n "${acrName}" "$MY_PATH/../Resources/k8sClusterAdmin-1.0.0.tgz" #--username a03158e9-58f5-4e5e-b11b-b5a2df77c661 --password FiS+yQNCI7GrX4jJ5ydyZOH9XmbCFCSBN70SdiwwtWg=

##########################################################################################
# Above can be removed if helm chart is packaged and pushed outside of this script
##########################################################################################

# Assuming helm chart already exists (if not use the same as above commands to package and push to ACR repository)
# this is needed to get a new authentication token if you are trying to pull the chart in the same session
# if above is not done helm will not be able to download the chart and will give you un-authorized error.  
# Refer https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos#install-a-helm-chart-from-the-repository
helm repo update
az acr helm repo add
echo "Installing helm chart for cluster admins on aks cluster ... with group id '${k8sAdminGroupId}'"
helm install "${acrName}/k8sClusterAdmin" --set adminAADGroupId="${k8sAdminGroupId}"