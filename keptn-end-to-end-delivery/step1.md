Keptn uses a declarative approach to build scalable automation for delivery and operations which can be scaled to a large number of services.

This Killercoda scenario comes pre installed with helm3, a single node K3s cluster and Istio installed. 

First of all, you will need to create a cluster for Keptn, and then install and configure Keptn itself.
We'll run Keptn on a local k3s cluster.
## Check the cluster

In order to check the cluster just run  `kubectl cluster-info &&
kubectl get nodes`{{execute}}

 ## Install and expose keptn

 Every Keptn release provides binaries for the Keptn CLI. These binaries are available for Linux, macOS, and Windows.
 To install the latest release of Keptn with full quality gate + continuous delivery capabilities in your Kubernetes cluster, execute the keptn install command.

`curl -sL https://get.keptn.sh | KEPTN_VERSION=0.15.1 bash &&
helm install keptn https://github.com/keptn/keptn/releases/download/0.15.1/keptn-0.15.1.tgz -n keptn --create-namespace`{{execute}}


Once you have all pods running on the cluster as below, you can go ahead and execute the next command:
```
NAME                         READY   STATUS
bridge-*                     1/1     Running
approval-service-*           2/2     Running
api-gateway-nginx-*          1/1     Running
webhook-service-*            2/2     Running
lighthouse-service-*         2/2     Running
keptn-mongo-*                1/1     Running
remediation-service-*        2/2     Running
configuration-service-*      1/1     Running
secret-service-*             1/1     Running
keptn-nats-cluster-0         2/2     Running
api-service-*                2/2     Running
mongodb-datastore-*          2/2     Running
shipyard-controller-*        2/2     Running
statistics-service-*         2/2     Running
job-executor-service-*       2/2     Running
```
You can check all the pods if running with this below command:
`watch kubectl get pods -n keptn`{{execute}}

# Install Job Executor Service 0.2.0:

It allows you to run customizable tasks with Keptn as Kubernetes Jobs

`KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)`{{execute}}

`helm install \
--namespace keptn-jes --create-namespace \
--wait --timeout=10m \
--set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn \
--set=remoteControlPlane.api.token=$KEPTN_API_TOKEN \
--set=remoteControlPlane.topicSubscription="sh.keptn.event.hello-world.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz`{{execute}}

# Expose Keptn via an Ingress:

Run the following to expose the bridge (UI) on a loadBalancer.

`helm upgrade keptn https://github.com/keptn/keptn/releases/download/0.13.1/keptn-0.15.1.tgz -n keptn --set=control-plane.apiGatewayNginx.type=LoadBalancer`{{execute}}

# Traffic Port Accessor 

<!-- `kubectl port-forward --address 0.0.0.0 service/api-gateway-nginx 80:80 -n keptn`{{execute}} -->

Get Keptn endpoint: Get the EXTERNAL-IP of the api-gateway-ngix using the command below. The Keptn API endpoint is: `http://<ENDPOINT_OF_API_GATEWAY>/api`

`export KEPTN_ENDPOINT=$(kubectl -n keptn get ingress api-keptn-ingress -ojsonpath='{.spec.rules[0].host}')`{{execute}}

`echo "Keptn Available at: http://$KEPTN_ENDPOINT"`{{execute}}

This may take a while to get an access to the the `keptn bridge endpoint`. The expected outcome is something like `Keptn Available at: http://172.X.Y.Z`.

# Authenticate Keptn CLI

Please make sure you get the endpoint as above before you encounter this command.

`keptn auth --endpoint=$KEPTN_ENDPOINT`{{execute}}