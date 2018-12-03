#!/bin/bash
set -o xtrace

subscriptionId=$1
tenantId=$2
clientId=$3
clientSecret=$4

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

helm init --upgrade --wait

echo "Adding google service catalog repo"
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

echo "Install Service Catalog"
helm install svc-cat/catalog --name catalog --namespace catalog --wait
helm install svc-cat/catalog --name catalog --namespace catalog --set apiserver.storage.etcd.persistence.enabled=true --set apiserver.healthcheck.enabled=false --set controllerManager.healthcheck.enabled=false --set apiserver.verbosity=2 --set controllerManager.verbosity=2 --wait

echo "Getting status of apiservice"
kubectl get apiservice

echo "Add Open Service Broker for Azure Helm repository"
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

echo "Waiting for few mins to give some time for service catalog control manager and api server to be in running state...."
sleep 240 #wait for minute for serivce controller manager pods to be in ready state.

echo "Install the Open Service Broker for Azure using the Helm chart"
helm install azure/open-service-broker-azure --name osba --namespace osba --set azure.subscriptionId=${subscriptionId} --set azure.tenantId=${tenantId} --set azure.clientId=${clientId} --set azure.clientSecret=${clientSecret} --set image.pullPolicy=Always --wait --debug

