After installing and exposing Keptn, you can access the Keptn Bridge by using a browser and navigating to the Keptn endpoint without the api path at the end of the URL. You can also use the Keptn CLI to retrieve the Bridge URL using:

`keptn status`{{execute}}

## Authenticate Keptn Bridge

The Keptn Bridge has basic authentication enabled by default and the default user is keptn with an automatically generated password.

To get the username for authentication, execute:

`kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_USERNAME}" | base64 --decode`{{execute}}

To get the password for authentication, execute:

`kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_PASSWORD}" | base64 --decode`{{execute}}

Now, you can click on Dashboard tab, next to terminal tab which will ask you to authenticate the UI.

## Configure Keptn

`wget https://gist.githubusercontent.com/agardnerIT/8046b8a81bab90a37aef83219a8e8078/raw/341b6d3c8b8dfab30742320402706e903e5bb4ab/shipyard.yaml`{{execute}}
It looks like we have created shipyard deployment to the cluster

```
apiVersion: "spec.keptn.sh/0.2.2"
kind: "Shipyard"
metadata:
  name: "shipyard"
spec:
  stages:
    - name: "dev"
      sequences:
        - name: "hello"
          tasks:
            - name: "hello-world"
```
## Create Github stuff
- Create a GitHub PAT with full repo scope. Keptn will use this token to ensure all files and changes are synced to the upstream repo.
- Create a blank (uninitialised) repository for Keptn to work with. Do not add any files (not even a readme)
- Set some environment variables like below

`export GIT_USER=<YourGitUsername>
export GIT_REPO=https://github.com/<YourGitUserName>/<YourRepo>
export GIT_TOKEN=ghp_****`

Then create a project using `keptn create` command

`keptn create project hello-world --shipyard=shipyard.yaml --git-user=$GIT_USER --git-remote-url=$GIT_REPO --git-token=$GIT_TOKEN && 
keptn create service demo --project=hello-world`{{execute}}

Create a job config

`wget https://gist.githubusercontent.com/agardnerIT/1d4eaa1425832ee9a9036de92a20b3b7/raw/c0caddfcc3025fb16b55b21ea683ed7f1be328fe/jobconfig.yaml &&  
keptn add-resource --project=hello-world --service=demo --stage=dev --resource=jobconfig.yaml --resourceUri=job/config.yaml`{{execute}}

## Trigger Keptn

Trigger Keptn by sending a cloudevent to the API using the keptn send event command. A precrafted cloudevent is available for you:

`wget https://gist.githubusercontent.com/agardnerIT/005fc85fa86072d723a551a5708db21d/raw/d9efa71969657f7508403f82d0d214f878c4c9ca/hello.triggered.event.json && 
keptn send event -f hello.triggered.event.json`{{execute}}

Go to the Keptn bridge, into the sequence view of the hello-world project and you will be able to see the CD.
