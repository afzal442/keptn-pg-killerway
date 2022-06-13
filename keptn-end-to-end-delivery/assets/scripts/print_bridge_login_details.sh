echo ""
echo "======================================"
echo "Printing Keptn Bridge Login Details"
echo "======================================"
export BRIDGE_USERNAME=$(kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_USERNAME}" | base64 --decode)
export BRIDGE_PASSWORD=$(kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_PASSWORD}" | base64 --decode)
echo "Bridge Username: $BRIDGE_USERNAME"
echo "Bridge Password: $BRIDGE_PASSWORD"
