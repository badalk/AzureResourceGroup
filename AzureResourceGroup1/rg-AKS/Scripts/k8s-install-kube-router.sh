echo "Installing kube router"

MY_PATH="`dirname \"$0\"`"              # relative
echo "Current Path: $MY_PATH"

kubectl apply -f "$MY_PATH/../Resources/kuberouter-daemonset-deployment.yaml"

kubectl get daemonset kube-router -n kube-system

