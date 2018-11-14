subscriptionId=$1
tenantId=$2
clientId=$3
clientSecret=$4

helm init --upgrade

echo "Adding google service catalog repo"
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

echo "Install Service Catalog"
helm install svc-cat/catalog --name catalog --namespace catalog --set controllerManager.healthcheck.enabled=false

echo "Add Open Service Broker for Azure Helm repository"
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

echo "Install the Open Service Broker for Azure using the Helm chart"
helm install azure/open-service-broker-azure --name osba --namespace osba \
    --set azure.subscriptionId=${subscriptionId} \
    --set azure.tenantId=${tenantId} \
    --set azure.clientId=${clientId} \
    --set azure.clientSecret=${clientSecret}
