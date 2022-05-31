curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.1+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.1 sh -
export PATH="$PATH:/root/istio-1.12.1/bin"
istioctl install --set profile=demo -y
clear