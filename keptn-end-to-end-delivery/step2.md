## Set Git Details As Environment Variables

Keptn needs a brand new, uninitialised repo to store and manage configuration. We will create it automatically now.

Please run this helper script to set your details. If you make a mistake, just click this again to re-set things:

```
. ~/set_git_details.sh
```{{exec}}

Verify the details are correctly set by printing them to the console:

```
echo "Git Username: $GIT_USER"
echo "Git Token: $GITHUB_TOKEN"
echo "New Git Repo to be created: $GIT_NEW_REPO_NAME"
echo "URL of new Git Repo: $GIT_REPO"
```{{exec}}

## Create New Repository

The demo environment has the GitHub CLI. The CLI will automatically use the `GITHUB_TOKEN` environment variable to authenticate.

Ensure the GitHub CLI works by listing your existing repositories which should show all existing repositories on your account:

```
gh repo create $GIT_NEW_REPO_NAME --public
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
keptn create project fulltour --shipyard shipyard.yaml --git-remote-url $GIT_REPO --git-user $GIT_USER --git-token $GITHUB_TOKEN
keptn create service helloservice --project=fulltour
cd ~/keptn-job-executor-delivery-poc
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=./helm/helloservice.tgz --resourceUri=charts/helloservice.tgz
keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/basic.py
keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/locust.conf
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=job-executor-config.yaml --resourceUri=job/config.yaml
```{{exec}}

The Keptn project setup is now complete. Don't worry, we'll point you to a repository and docs at the end of the tutorial that will explain in-depth how all of this works.

It is now time to trigger your first end-to-end artifact delivery of the `helloservice.tgz` helm chart, testing along the way with locust.

## 🎉 Trigger Delivery

```
keptn trigger delivery \
--project=fulltour \
--service=helloservice \
--image="ghcr.io/podtato-head/podtatoserver:v0.1.1" \
--labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"
```{{exec}}

Locust runs for 2 minutes (configurable) each time it responds to `je-test.triggered`. Load is generated once in the `qa` stage so expect the end-to-end delivery with Locust load tests to take about 3 minutes.

View the delivery sequence [in the bridge]({{TRAFFIC_HOST1_8080}}/bridge/project/fulltour/sequence)

![deployed](./assets/trigger-delivery-2.jpg)
  
## While You Wait

While you are waiting for the release and load test to finish, why not have a look at your repo in a browser on GitHub.com.
  
Notice Keptn has created a branch per stage. Inside those branches are folders for each Keptn service.

The `keptn add-resource` command is a helper which ensures files are stored on the correct branches and in the correct folders. However, it is not mandatory to use this function; you could choose to upload directly to Git if you know your way around.

## What Happened?

Run `kubectl get namespaces`{{exec}}

Notice the 2 new namespaces: `fulltour-qa` and `fulltour-production`. Your app `helloservice.tgz` is deployed into each namespace thanks to the job executor service that ran `helm` (look at the `qa` and `production` branches in your repo at `helloservice/job/config.yaml`).

Helm is told to deploy `$(KEPTN_STAGE).tgz` (ie. `helloservice.tgz`).

```
NAME                  STATUS
default               Active
kube-system           Active
kube-public           Active
kube-node-lease       Active 
keptn                 Active  
keptn-jes             Active   
fulltour-qa           Active   2m
fulltour-production   Active   2m
```

## Validate Application Versions

Validate that pods version `v0.1.1` is running in both environments.

```
kubectl -n fulltour-qa describe pod -l app=helloservice | grep Image:
kubectl -n fulltour-production describe pod -l app=helloservice | grep Image:
```{{exec}}

> Result: Keptn orchestrated your deployment which was acheived using `helm` and `locust` to generate load.

----

## What Next?

Your application is being deployed into both QA and Production. This is great and indeed Keptn works with ArgoCD and Flux in the same way to ensure code is always up to date.

Sometimes, a manual approval step is required before an artifact is promoted to production. This is especially important right now as we are not testing the quality of the `helloservice` artifact. We will now add this.
