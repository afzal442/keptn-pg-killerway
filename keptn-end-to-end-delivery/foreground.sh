# Global variables
K3D_VERSION=v5.3.0
KUBECTL_VERSION=v1.22.6
KEPTN_VERSION=0.16.0
JOB_EXECUTOR_SERVICE_VERSION=0.2.0


echo "----------------------------------------"
echo "Step 1/6 Initialising Kubernetes..."
echo "----------------------------------------"
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$K3D_VERSION bash
k3d cluster create mykeptn -p "8080:80@loadbalancer" --k3s-arg "--no-deploy=traefik@server:*"

echo ""
echo "----------------------------------------"
echo "Step 2/6 Installing Kubectl"
echo "----------------------------------------"
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo ""
echo "----------------------------------------"
echo "Step 3/6 Installing Helm"
echo "----------------------------------------"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo ""
echo "----------------------------------------"
echo "Step 4/6 Installing Keptn CLI"
echo "----------------------------------------"
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

echo ""
echo "----------------------------------------"
echo "Step 5/6 Installing Keptn Control Plane"
echo "----------------------------------------"
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --timeout=2m --create-namespace --set=control-plane.apiGatewayNginx.type=LoadBalancer --wait

echo ""
echo "----------------------------------------"
echo "Step 5/6 Installing Job Executor Service"
echo "----------------------------------------"
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
helm install --namespace keptn-jes --create-namespace --timeout=2m --set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn --set=remoteControlPlane.api.token=$KEPTN_API_TOKEN --set=remoteControlPlane.topicSubscription="sh.keptn.event.je-deployment.triggered\,sh.keptn.event.je-test.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Installation Completed 🎉 . Please proceed now..."
