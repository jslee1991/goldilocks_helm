#!/bin/bash
HELM_CHART=/root/git/goldilocks_helm/goldilocks_helm/goldilocks-helm-chart/chart
PACKAGE_NAME=goldilocks

echo "helm deploy tool"

if [ "${1}" == "install" ] || [ "${1}" == "INSTALL" ]; then
	echo "installing ......."
	helm install -n $PACKAGE_NAME $HELM_CHART

elif [ "${1}" == "upgrade" ] || [ "${1}" == "UPGRADE" ]; then
	echo "upgrading ......."
	helm upgrade $PACKAGE_NAME $HELM_CHART

elif [ "${1}" == "delete" ] || [ "${1}" == "DELETE" ]; then
	echo "deleting ......."
	helm delete $PACKAGE_NAME --purge

else 
	echo "error, check ur args.."
fi
