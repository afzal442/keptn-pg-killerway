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

[ACCESS KEPTN BRIDGE]({{TRAFFIC_HOST1_80}})

![UI View](./assets/keptn-hello-world.jpg)

## Configure Keptn

To configure the keptn, we need to create a shipyard.yaml file 

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
It looks like we have created shipyard deployment to the cluster

OR

Pull the `shipyard.yaml` into your repo using `wget`

`wget https://gist.githubusercontent.com/agardnerIT/8046b8a81bab90a37aef83219a8e8078/raw/341b6d3c8b8dfab30742320402706e903e5bb4ab/shipyard.yaml`{{execute}}

<!-- ## Create Github stuff
- Create a GitHub PAT with full repo scope. Keptn will use this token to ensure all files and changes are synced to the upstream repo.
- Create a blank (uninitialised) repository for Keptn to work with. Do not add any files (not even a readme)
- Set some environment variables like below

`export GIT_USER=<YourGitUsername>
export GIT_REPO=https://github.com/<YourGitUserName>/<YourRepo>
export GIT_TOKEN=ghp_****` -->

Create a project using `keptn create` command

<!-- --git-user=$GIT_USER --git-remote-url=$GIT_REPO --git-token=$GIT_TOKEN -->

`keptn create project hello-world --shipyard=shipyard.yaml && 
keptn create service demo --project=hello-world`{{execute}}

Create a job config yaml file as below and save it as jobconfig.yaml

```
apiVersion: v2
actions:
  - name: "Run alpine image to say hello world"
    events:
      - name: "sh.keptn.event.hello-world.triggered"
    tasks:
      - name: "Say Hello World"
        image: "alpine"
        cmd:
          - echo
        args:
          - 'Hello, world!'
```
OR

Pull the `jobconfig.yaml` into your repo using `wget` 

`wget https://gist.githubusercontent.com/agardnerIT/1d4eaa1425832ee9a9036de92a20b3b7/raw/c0caddfcc3025fb16b55b21ea683ed7f1be328fe/jobconfig.yaml`{{execute}}

Add a resource using `keptn` CLI

`keptn add-resource --project=hello-world --service=demo --stage=dev --resource=jobconfig.yaml --resourceUri=job/config.yaml`{{execute}}

#### Trigger Keptn

Trigger Keptn by sending a cloudevent to the API using the keptn send event command. A precrafted cloudevent is available for you:

Create a xyz.event.json file and save it as hello.triggered.event.json

```
{
  "specversion": "1.0",
  "type": "sh.keptn.event.dev.hello.triggered",
  "source": "hello-world demo",
  "datacontenttype": "application/json",
  "data": {
    "project": "hello-world",
    "service": "demo",
    "stage": "dev"
  }
}
```
OR

Pull the json file `hello.triggered.event.json` into your repo using `wget`

`wget https://gist.githubusercontent.com/agardnerIT/005fc85fa86072d723a551a5708db21d/raw/d9efa71969657f7508403f82d0d214f878c4c9ca/hello.triggered.event.json`{{execute}}

## Send the event through keptn

`keptn send event -f hello.triggered.event.json`{{execute}}

Go to the Keptn bridge, into the sequence view of the hello-world project and you will be able to see the CD.
