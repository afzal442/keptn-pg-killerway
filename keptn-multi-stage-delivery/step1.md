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

`curl -sL https://get.keptn.sh | KEPTN_VERSION=0.14.1 bash &&
keptn install --endpoint-service-type=ClusterIP --use-case=continuous-delivery`{{execute}}


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

# Configure Istio

We are using Istio for traffic routing and as an ingress to our cluster. To make the setup experience as smooth as possible we have provided some scripts for your convenience. If you want to run the Istio configuration yourself step by step, please take a look at the [Keptn documentation](https://keptn.sh/docs/0.14.x/operate/install/#option-3-expose-keptn-via-an-ingress).

Download the configuration bash script and run the configuration script to automatically create your Ingress resources

`curl -o configure-istio.sh https://raw.githubusercontent.com/keptn/examples/0.11.0/istio-configuration/configure-istio.sh && 
chmod +x configure-istio.sh && ./configure-istio.sh`{{execute}}

Finally, the script restarts the helm-service pod of Keptn to fetch this new configuration.


# Expose Keptn via an Ingress:

Run the following to expose the bridge (UI) using ngnix api-gateway.

`kubectl -n keptn get ingress api-keptn-ingress
`{{execute}}

# Traffic Port Accessor 

<!-- `kubectl port-forward --address 0.0.0.0 service/api-gateway-nginx 80:80 -n keptn`{{execute}} -->

Get Keptn endpoint: Get the EXTERNAL-IP of the api-gateway-ngix using the command below. The Keptn API endpoint is: `http://<ENDPOINT_OF_API_GATEWAY>/api`

`export KEPTN_ENDPOINT=$(kubectl -n keptn get ingress api-keptn-ingress -ojsonpath='{.spec.rules[0].host}')`{{execute}}

`echo "Keptn Available at: http://$KEPTN_ENDPOINT"`{{execute}}

This may take a while to get an access to the the `keptn bridge endpoint`. The expected outcome is something like `Keptn Available at: http://172.X.Y.Z`.

# Authenticate Keptn CLI

Please make sure you get the endpoint as above before you encounter this command.

`keptn auth --endpoint=$KEPTN_ENDPOINT`{{execute}}