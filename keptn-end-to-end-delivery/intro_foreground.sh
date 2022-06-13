# -----------------------------------------#
#        Setting Global variables          #
# -----------------------------------------#
DEBUG=18
K3D_VERSION=v5.3.0
KUBECTL_VERSION=v1.22.6
GH_CLI_VERSION=2.12.1
KEPTN_VERSION=0.15.1
JOB_EXECUTOR_SERVICE_VERSION=0.2.0
KEPTN_PROMETHEUS_SERVICE_VERSION=0.8.0

# -----------------------------------------#
#    Step 1/11: Installing GitHub CLI      #
# -----------------------------------------#
wget -q https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.deb
chmod +x gh_${GH_CLI_VERSION}_linux_amd64.deb
dpkg -i gh_${GH_CLI_VERSION}_linux_amd64.deb
wget -q https://gist.githubusercontent.com/agardnerIT/e3dadfaa303d96fc131f3f0f4664c7cc/raw/98a9f8baaf41efb7e11b93e4a57014142d508af8/set_git_details.sh
wget -q https://gist.githubusercontent.com/agardnerIT/9225e81f42b47edeffc69443da4dbaea/raw/2d9f5e7d6f3897b0206017bd362bc4335f841d40/setup_keptn.sh
wget -q https://gist.githubusercontent.com/agardnerIT/886ea4952d0ab9208679212bea2b26d0/raw/cb8b0699ead7114d6f79ed5533a56ca247152456/print_bridge_login_details.sh
wget -q https://gist.githubusercontent.com/agardnerIT/7e91b9ceb0ddffec4f1061e3271515fc/raw/ca5f236e55f1d90835de02097c62c0697ff8aac7/add_approval_step.sh
wget -q https://gist.githubusercontent.com/agardnerIT/597e18923ad852b2595ccb3e14ac6ca9/raw/ac33ca5eb316959338c0f1ea743c819138aa3fb9/quality_gated_release.sh
wget -q https://gist.githubusercontent.com/agardnerIT/d2a6cb29c679243f143ebcec7360dd50/raw/01cc7f9e01b89b659bdfb638ad6d8f0da9b5abaa/release_validation.sh
wget -q https://gist.githubusercontent.com/agardnerIT/f3beeb80b4f4c07173a5f515b3818d33/raw/419b67414eba11d0279d8f52463ebdb95f99ab0c/self_healing.sh

chmod +x set_git_details.sh
chmod +x setup_keptn.sh
chmod +x print_bridge_login_details.sh
chmod +x add_approval_step.sh
chmod +x quality_gated_release.sh
chmod +x release_validation.sh
chmod +x self_healing.sh

# -----------------------------------------#
#    Step 2/11: Retrieving demo files      #
# -----------------------------------------#
git clone https://github.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc.git

# -----------------------------------------#
#      Step 3/11: Installing Keptn CLI     #
# -----------------------------------------#
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

# ----------------------------------------#
#      Step 4/11: Installing Helm         #
# ----------------------------------------#
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh
./get_helm.sh

# ----------------------------------------#
#      Step 5/11: Installing Kubectl      #
# ----------------------------------------#
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# -----------------------------------------#
#    Step 6/11: Initialising Kubernetes    #
# -----------------------------------------#
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=$K3D_VERSION bash
k3d cluster create mykeptn -p "8080:80@loadbalancer" --k3s-arg "--no-deploy=traefik@server:*"


# -----------------------------------------#
#    Step 7/11: Installing Prometheus      #
# -----------------------------------------#
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace

# -------------------------------------------#
# Step 8/11: Installing Keptn Control Plane  #
# -------------------------------------------#
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --timeout=5m --wait --create-namespace --set=control-plane.apiGatewayNginx.type=LoadBalancer

# --------------------------------------------#
# Step 9/11: Installing Job Executor Service  #
# --------------------------------------------#
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
helm install --namespace keptn-jes --create-namespace --wait --timeout=4m --set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn --set=remoteControlPlane.api.token=$KEPTN_API_TOKEN --set=remoteControlPlane.topicSubscription="sh.keptn.event.je-deployment.triggered\,sh.keptn.event.je-test.triggered\,sh.keptn.event.action.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz

# --------------------------------------------#
# Step 10/11: Installing Prometheus Service   #
# --------------------------------------------#
helm install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/$KEPTN_PROMETHEUS_SERVICE_VERSION/prometheus-service-$KEPTN_PROMETHEUS_SERVICE_VERSION.tgz --set resources.requests.cpu=25m
kubectl -n monitoring apply -f https://raw.githubusercontent.com/keptn-contrib/prometheus-service/$KEPTN_PROMETHEUS_SERVICE_VERSION/deploy/role.yaml

# ---------------------------------------------#
# Step 11/11: Apply Cluster Admin Role for JES #
# ---------------------------------------------#
kubectl apply -f ~/keptn-job-executor-delivery-poc/job-executor/workloadClusterRoles.yaml

# ---------------------------------------------#
#       🎉 Installation Complete 🎉          #
#           Please proceed now...              #
# ---------------------------------------------#
