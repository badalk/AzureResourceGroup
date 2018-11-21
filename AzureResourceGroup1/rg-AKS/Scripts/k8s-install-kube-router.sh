#!/bin/bash
set -o xtrace

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

echo "Installing kube router"

MY_PATH="`dirname \"$0\"`"              # relative
echo "Current Path: $MY_PATH"

kubectl apply -f "$MY_PATH/../Resources/kuberouter-daemonset-deployment.yaml"

kubectl get daemonset kube-router -n kube-system

