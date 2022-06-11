After installing and exposing Keptn, you can access the Keptn Bridge by using a browser and navigating to the Keptn endpoint without the api path at the end of the URL. You can also use the Keptn CLI to retrieve the Bridge URL using:

`keptn status`{{execute}}

## Authenticate Keptn Bridge

The Keptn Bridge has basic authentication enabled by default and the default user is keptn with an automatically generated password.

To get the username for authentication, execute:

`kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_USERNAME}" | base64 --decode`{{execute}}

To get the password for authentication, execute:

`kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_PASSWORD}" | base64 --decode`{{execute}}

Now, you can click on Dashboard tab, next to terminal tab which will ask you to authenticate the UI.

## Visualization 

You can also view the trigerred result in a UI

[Access Keptns Bridge (UI)]({{TRAFFIC_HOST1_8080}})

![UI View](./assets/keptn-hello-world.jpg)

## Create and Gather Github Details

![git repo](./assets/repo-token.png)

- Create a GitHub PAT with full repo scope. Keptn will use this token to ensure all files and changes are synced to the upstream repo.
- Create a blank (uninitialised) repository for Keptn to work with. Do not add any files (not even a readme)
- Set these details as environment variables

```
export GIT_USER=<YourGitUsername>
export GIT_REPO=https://github.com/<YourGitUserName>/<YourRepo>
export GIT_TOKEN=ghp_****
```

## Configure Keptn

To configure Keptn, we need to create a `shipyard.yaml` file. A shipyard file defines the Keptn environment.

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

Now, create the project as `fulltour` and service called `helloservice` using Keptn CLI
`service` name must be called precisely that because the helm chart we use is called `helloservice.tgz` and the job executor runs `helm install` and relies on a file being available called `helloservice.tgz`.


```
keptn create project fulltour --shipyard shipyard.yaml --git-remote-url $GIT_REPO --git-user $GIT_USER --git-token $GIT_TOKEN
keptn create service helloservice --project=fulltour
```{{exec}}

Note you can also achieve this via the [API]({{TRAFFIC_HOST1_8080}}/api) or the [Bridge (UI)]({{TRAFFIC_HOST1_8080}}/bridge)

## Retrieve Required Files

Provide keptn with the important files it needs during the sequence execution. Your choice: Either upload directly to the upstream Git repo or use the keptn add resource commands. The result is the same. keptn add resource is just a helpful wrapper around git add / commit / push

In the web terminal, download all necessary files for this tutorial:

`git clone https://github.com/christian-kreuzberger-dtx/keptn-job-executor-delivery-poc.git`{{execute}}

## Provide additional permissions for Job Executor Service
This gives the `helm deploy` task full cluster-admin access to your Kubernetes cluster. This is not recommended for production setups, but it is needed for this demo to work (e.g., `helm upgrade` needs to be able to create namespaces, secrets, …)

`kubectl apply -f ~/keptn-job-executor-delivery-poc/job-executor/workloadClusterRoles.yaml`{{execute}}

## Add Application Helm Chart

Add the helm chart (this is the real application we will deploy). The `--resource` path is the path to files on disk whereas `--resourceUri` is the Git target folder. Do not change these. Notice also we’re uploading a helm chart with a name matching the keptn service: `helloservice.tgz`

```
cd keptn-job-executor-delivery-poc
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=./helm/helloservice.tgz --resourceUri=charts/helloservice.tgz
```{{execute}}

Add the files that locust needs:

`keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/basic.py`{{execute}}

`keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/locust.conf`{{execute}}

Add the job executor service config file. This tells the JES what container and commands to execute for each keptn task:

```
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=job-executor-config.yaml --resourceUri=job/config.yaml
```{{execute}}

## 🎉 Trigger Delivery

You are now ready to trigger delivery of the helloservice helm chart into all stages, testing along the way with locust:

You can trigger a sequence via the keptn’s API, via the bridge UI or via the keptn CLI:

```
keptn trigger delivery --project=fulltour --service=helloservice --image="ghcr.io/podtato-head/podtatoserver:v0.1.1" --labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"
```{{execute}}

## Verify QA and Production Deployments

When the Keptn sequence has completed, two new namespaces will exist: `fulltour-qa` and `fulltour-production`. The `podtatohead` application will be deploy in each namespace. These mimic our environments.

Validate that pods version `v0.1.1` is running in both environments.

```
kubectl -n fulltour-qa describe pod -l app=helloservice | grep Image:
kubectl -n fulltour-production describe pod -l app=helloservice | grep Image:
```{{exec}}
