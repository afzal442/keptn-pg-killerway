# -----------------------------------------#
#        Setting Global variables          #
# -----------------------------------------#
DEBUG_VERSION=2
KUBECTL_VERSION=v1.22.6
GH_CLI_VERSION=2.23.0
KEPTN_VERSION=1.3.0
JOB_EXECUTOR_SERVICE_VERSION=0.3.0
JOB_EXECUTOR_NAMESPACE=keptn-jes
KEPTN_PROMETHEUS_SERVICE_VERSION=0.9.1
PROMETHEUS_VERSION=19.0.1
POD_WAIT_TIMEOUT_MINS=10

# ----------------------------------------#
#      Step 1/9: Installing Kubectl      #
# ----------------------------------------#
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# ----------------------------------------#
#      Step 2/9: Installing Helm         #
# ----------------------------------------#
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh
./get_helm.sh

# -------------------------------------------#
# Step 3/9: Installing Keptn Control Plane  #
# -------------------------------------------#
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz \
-n keptn --create-namespace \
--set=apiGatewayNginx.type=LoadBalancer \
--set mongo.resources.requests.cpu=0 \
--set mongo.resources.requests.memory=0 \
--set nats.nats.resources.requests.cpu=0 \
--set nats.nats.resources.requests.memory=0 \
--set nats.nats.jetstream.memStorage.size=0M \
--set apiGatewayNginx.resources.requests.cpu=0 \
--set apiGatewayNginx.resources.requests.memory=0 \
--set remediationService.resources.requests.cpu=0 \
--set remediationService.resources.requests.memory=0 \
--set apiService.resources.requests.cpu=0 \
--set apiService.resources.requests.memory=0 \
--set bridge.versionCheck.enabled=false \
--set bridge.resources.requests.cpu=0 \
--set bridge.resources.requests.memory=0 \
--set distributor.resources.requests.cpu=0 \
--set distributor.resources.requests.memory=0 \
--set shipyardController.resources.requests.cpu=0 \
--set shipyardController.resources.requests.memory=0 \
--set secretService.resources.requests.cpu=0 \
--set secretService.resources.requests.memory=0 \
--set configurationService.resources.requests.cpu=0 \
--set configurationService.resources.requests.memory=0 \
--set resourceService.resources.requests.cpu=0 \
--set resourceService.resources.requests.memory=0 \
--set mongodbDatastore.resources.requests.cpu=0 \
--set mongodbDatastore.resources.requests.memory=0 \
--set lighthouseService.resources.requests.cpu=0 \
--set lighthouseService.resources.requests.memory=0 \
--set statisticsService.enabled=false \
--set approvalService.resources.requests.cpu=0 \
--set approvalService.resources.requests.memory=0 \
--set webhookService.resources.requests.cpu=0 \
--set webhookService.resources.requests.memory=0

# -----------------------------------------#
#    Step 4/9: Installing Prometheus      #
# -----------------------------------------#
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus \
--namespace monitoring --create-namespace \
--version ${PROMETHEUS_VERSION}

# --------------------------------------------#
# Step 5/9: Installing Prometheus Service   #
# --------------------------------------------#
helm install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/$KEPTN_PROMETHEUS_SERVICE_VERSION/prometheus-service-$KEPTN_PROMETHEUS_SERVICE_VERSION.tgz --set resources.requests.cpu=0m

# --------------------------------------------#
# Step 6/9: Installing Job Executor Service  #
# --------------------------------------------#
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
helm install --namespace $JOB_EXECUTOR_NAMESPACE \
--create-namespace \
--set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn \
--set=remoteControlPlane.api.token=$KEPTN_API_TOKEN --set=remoteControlPlane.topicSubscription="sh.keptn.event.deployment.triggered\,sh.keptn.event.test.triggered\,sh.keptn.event.action.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz
kubectl apply -f https://raw.githubusercontent.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc/main/job-executor/workloadClusterRoles.yaml

# -----------------------------------------#
#      Step 7/9: Installing Keptn CLI     #
# -----------------------------------------#
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

# -----------------------------------------#
#    Step 8/9: Installing GitHub CLI      #
# -----------------------------------------#
wget -q https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.deb
chmod +x gh_${GH_CLI_VERSION}_linux_amd64.deb
dpkg -i gh_${GH_CLI_VERSION}_linux_amd64.deb

# -----------------------------------------#
#    Step 9/9: Wait for all pods         #
# -----------------------------------------#
kubectl -n monitoring wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/prometheus-kube-state-metrics
kubectl -n monitoring wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/prometheus-prometheus-pushgateway
#kubectl -n monitoring wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/prometheus-alertmanager
kubectl -n monitoring wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/prometheus-server
kubectl -n keptn-jes wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/job-executor-service
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/api-gateway-nginx
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/resource-service
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/secret-service
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/api-service
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/bridge
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/mongodb-datastore
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/keptn-mongo
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/shipyard-controller
#kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/remediation-service
#kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/approval-service
#kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/webhook-service
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/lighthouse-service
kubectl -n keptn wait --for condition=Available=True --timeout=${POD_WAIT_TIMEOUT_MINS}m deployment/prometheus-service

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#
