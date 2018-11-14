echo "..............................................................."
echo "         Installing kube-router for interpod networking        "
echo "..............................................................."

MY_PATH="`dirname \"$0\"`"              # relative
echo "$MY_PATH"

kubectl apply -f "$MY_PATH/../Resources/kuberouter-daemonset-deployment.yaml"

kubectl get daemonset kube-router -n kube-system

