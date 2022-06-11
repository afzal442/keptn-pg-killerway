echo "Initialising Kubernetes..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.1+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
echo "### WAIT FOR keptn TO BE READY ### (this can take a few minutes)"
curl -sL https://get.keptn.sh | KEPTN_VERSION=0.13.1 bash &&
helm install keptn https://github.com/keptn/keptn/releases/download/0.13.1/keptn-0.13.1.tgz -n keptn --create-namespace --wait
clear
echo "Installation Completed 🎉 . Please proceed now..."