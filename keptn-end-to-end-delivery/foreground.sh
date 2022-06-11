# -----------------------------------------#
#        Setting Global variables          #
# -----------------------------------------#
DEBUG=v1
K3D_VERSION=v5.3.0
KUBECTL_VERSION=v1.22.6
GH_CLI_VERSION=2.12.1
KEPTN_VERSION=0.15.1
JOB_EXECUTOR_SERVICE_VERSION=0.2.0

# -----------------------------------------#
#    Step 1/9: Retrieving demo files       #
# -----------------------------------------#
git clone https://github.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc.git

# -----------------------------------------#
#    Step 2/9: Installing GitHub CLI       #
# -----------------------------------------#
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

echo "got here..."

# -----------------------------------------#
#      Step 3/9: Installing Keptn CLI      #
# -----------------------------------------#
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

# ----------------------------------------#
#      Step 4/9: Installing Helm          #
# ----------------------------------------#
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh
./get_helm.sh

# ----------------------------------------#
#      Step 5/9: Installing Kubectl       #
# ----------------------------------------#
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# -----------------------------------------#
#    Step 6/9: Initialising Kubernetes     #
# -----------------------------------------#
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$K3D_VERSION bash
k3d cluster create mykeptn -p "8080:80@loadbalancer" --k3s-arg "--no-deploy=traefik@server:*"

# -------------------------------------------#
# Step 7/9: Installing Keptn Control Plane   #
# -------------------------------------------#
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --timeout=5m --wait --create-namespace --set=control-plane.apiGatewayNginx.type=LoadBalancer

# --------------------------------------------#
# Step 8/9: Installing Job Executor Service   #
# --------------------------------------------#
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
helm install --namespace keptn-jes --create-namespace --wait --timeout=4m --set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn --set=remoteControlPlane.api.token=$KEPTN_API_TOKEN --set=remoteControlPlane.topicSubscription="sh.keptn.event.je-deployment.triggered\,sh.keptn.event.je-test.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz

# --------------------------------------------#
# Step 9/9: Apply Cluster Admin Role for JES  #
# --------------------------------------------#
kubectl apply -f ~/keptn-job-executor-delivery-poc/job-executor/workloadClusterRoles.yaml


# ------------------------------------------#
#       🎉 Installation Completed 🎉        #
#           Please proceed now...           #
# ------------------------------------------#
