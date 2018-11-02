echo "..............................................................."
echo "         Installing kube-router for interpod networking        "
echo "..............................................................."

kubectl apply -f https://raw.githubusercontent.com/marrobi/kube-router/marrobi/aks-yaml/daemonset/kube-router-firewall-daemonset-aks.yaml

kubectl get daemonset kube-router -n kube-system

