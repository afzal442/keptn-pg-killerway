
First, check the cluster is up and running then install and configure Keptn.

## Check the cluster

In order to check the cluster just run:

```
kubectl cluster-info
kubectl get nodes
```{{exec}}

 ## Install and Expose Keptn

 Every Keptn release provides binaries for the Keptn CLI. These binaries are available for Linux, macOS, and Windows.
 To install the latest release of Keptn with continuous delivery capabilities in your Kubernetes cluster, execute the keptn install command.

```
curl -sL https://get.keptn.sh | KEPTN_VERSION=0.16.0 bash
helm install keptn https://github.com/keptn/keptn/releases/download/0.16.0/keptn-0.16.0.tgz -n keptn --create-namespace --set=control-plane.apiGatewayNginx.type=LoadBalancer --wait
```{{exec}}

Note: During installation the Keptn pods [are known](https://github.com/keptn/keptn/issues/7580) to `Error` and `CrashLoopBackOff` until everything "settles down". So expect errors for the first few minutes. After a few moments everything will be in a `Running` state.

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
```

You can check all the pods if running with this below command (`ctrl + c` to exit):
`watch kubectl get pods -n keptn`{{execute}}

## Install Job Executor Service

It allows you to run customizable tasks with Keptn as Kubernetes Jobs

```
export KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
export JOB_EXECUTOR_SERVICE_VERSION=0.2.0
helm install --namespace keptn-jes --create-namespace --timeout=10m --set=remoteControlPlane.api.hostname=api-gateway-nginx.keptn --set=remoteControlPlane.api.token=$KEPTN_API_TOKEN --set=remoteControlPlane.topicSubscription="sh.keptn.event.je-deployment.triggered\,sh.keptn.event.je-test.triggered" \
job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/$JOB_EXECUTOR_SERVICE_VERSION/job-executor-service-$JOB_EXECUTOR_SERVICE_VERSION.tgz
```{{execute}}

### Authenticate Keptn CLI

The Keptn CLI needs to authenticate with the control-plane (running on the Kubernetes cluster). Authenticate it now:

```
export KEPTN_ENDPOINT=$(kubectl get services -n keptn api-gateway-nginx -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
export KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 -d)
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
```{{execute}}

This command is also available in the Keptns Bridge if you ever forget it.

`keptn status`{{exec}} should show:

```
$ keptn status
Starting to authenticate
Successfully authenticated against the Keptn cluster http://172.18.0.3/api
Bridge URL: http://172.18.0.3/bridge
Using a file-based storage for the key because the password-store seems to be not set up.
```

The Bridge and API are available in Killercoda:

1. Navigate to the menu icon (three lines on the top right)
2. Select `Traffic / Ports`
3. Click Port `8080` to access the bridge
4. A link to the API is found under the "little person" icon (top right)

To retrieve the Keptn bridge username (defaults to `keptn`):

```
kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_USERNAME}" | base64 --decode ; echo
```{{exec}}

To retrieve the Keptn bridge password (randomly generated during installation):
```
kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_PASSWORD}" | base64 --decode ; echo
```{{exec}}
