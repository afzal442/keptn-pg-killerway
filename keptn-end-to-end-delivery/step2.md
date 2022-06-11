## Create Keptn Project

A Keptn project is a high level logical container. A project contains stages (which mimic your environment eg. `dev` and `production`) and services (which mimic your microservices).

A Keptn project is modelled by a `shipyard.yaml` file which you must define.

Run the following to create a `shipyard.yaml` file on disk:

```
cd ~
cat << EOF > shipyard.yaml
apiVersion: "spec.keptn.sh/0.2.2"
kind: "Shipyard"
metadata:
  name: "shipyard-delivery"
spec:
  stages:
    - name: "qa"
      sequences:
        - name: "delivery"
          tasks:
            - name: "je-deployment"
            - name: "je-test"

    - name: "production"
      sequences:
        - name: "delivery"
          triggeredOn:
            - event: "qa.delivery.finished"
          tasks:
            - name: "je-deployment"
EOF
```{{exec}}

Create the project: `fulltour` and service called `helloservice` using the Keptn CLI.

The Keptn service name must be called precisely `helloservice` because the helm chart we use in this demo is called `helloservice.tgz` and the job executor runs `helm install` and relies on a file being available called `helloservice.tgz`.


```
keptn create project fulltour --shipyard shipyard.yaml --git-remote-url $GIT_REPO --git-user $GIT_USER --git-token $GIT_TOKEN
keptn create service helloservice --project=fulltour
```{{exec}}

You can also achieve this via the [API]({{TRAFFIC_HOST1_8080}}/api) or the [Bridge (UI)]({{TRAFFIC_HOST1_8080}}/bridge)

## Retrieve Required Files

Provide keptn with the important files it needs during the sequence execution. Your choice: Either upload directly to the upstream Git repo or use the `keptn add-resource` commands. The result is the same. `keptn add-resource` is just a helpful wrapper around `git add / commit / push`

In the web terminal, download all necessary files for this tutorial:

`git clone https://github.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc.git`{{execute}}

## Job Executor Service: Add Additional Permissions

For this tutorial, helm needs full `cluster-admin` access. This is not recommended for production setups, but it is needed for this demo to work (e.g., `helm upgrade` needs to be able to create namespaces, secrets, …)

`kubectl apply -f ~/keptn-job-executor-delivery-poc/job-executor/workloadClusterRoles.yaml`{{exec}}

## Add Application Helm Chart

Add the helm chart (this is the real application we will deploy). The `--resource` path is the path to files on disk whereas `--resourceUri` is the Git target folder. Do not change these. Notice also we’re uploading a helm chart with a name matching the keptn service: `helloservice.tgz`

```
cd keptn-job-executor-delivery-poc
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=./helm/helloservice.tgz --resourceUri=charts/helloservice.tgz
```{{exec}}

Add the files that locust needs:

```
keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/basic.py
keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/locust.conf
```{{exec}}

Add the job executor service config file. This tells the JES what container and commands to execute for each keptn task:

```
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=job-executor-config.yaml --resourceUri=job/config.yaml
```{{execute}}

## 🎉 Trigger Delivery

You are now ready to trigger delivery of the `helloservice` helm chart into all stages, testing along the way with locust:

Trigger a sequence via the Keptns API, via the bridge UI or via the keptn CLI:

```
keptn trigger delivery --project=fulltour --service=helloservice --image="ghcr.io/podtato-head/podtatoserver:v0.1.1" --labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"
```{{exec}}

## Verify QA and Production Deployments

When the Keptn sequence has completed, two new namespaces will exist: `fulltour-qa` and `fulltour-production`. The `podtatohead` application will be deploy in each namespace. These mimic our environments.

Validate that pods version `v0.1.1` is running in both environments.

```
kubectl -n fulltour-qa describe pod -l app=helloservice | grep Image:
kubectl -n fulltour-production describe pod -l app=helloservice | grep Image:
```{{exec}}
