curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.3.0 bash
k3d cluster create mykeptn -p "8082:80@loadbalancer" --k3s-arg "--no-deploy=traefik@server:*"
export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.1 sh -
export PATH="$PATH:/root/istio-1.12.1/bin"
istioctl install --set profile=demo -y
clear