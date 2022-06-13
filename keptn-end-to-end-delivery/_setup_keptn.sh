#
# IMPORTANT: Killercoda should be able to add this file to the VM but it isn't currently working
# So for now I'll wget it from a private Git in the intro_foreground.sh
# But this is anticipated to be a temporary workaround and as soon as Killercoda works we'll pull everything from this repo
#
cd
echo ""
echo "================================================================================="
echo " Creating brand new Git repo ($GIT_NEW_REPO_NAME) on your GitHub.com account     "
echo "================================================================================="
gh repo create $GIT_NEW_REPO_NAME --public
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

echo ""
echo "================================================================================="
echo " Creating Keptn project (fulltour) and a Keptn service (helloservice)            "
echo "================================================================================="
keptn create project fulltour --shipyard shipyard.yaml --git-remote-url $GIT_REPO --git-user $GIT_USER --git-token $GITHUB_TOKEN
keptn create service helloservice --project=fulltour
cd ~/keptn-job-executor-delivery-poc

echo ""
echo "================================================================================="
echo "Adding Helm Chart (helloservice.tgz), Locust files and Job Executor Service files to Git"
echo "================================================================================="
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=./helm/helloservice.tgz --resourceUri=charts/helloservice.tgz
keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/basic.py
keptn add-resource --project=fulltour --service=helloservice --stage=qa --resource=./locust/locust.conf
keptn add-resource --project=fulltour --service=helloservice --all-stages --resource=job-executor-config.yaml --resourceUri=job/config.yaml

echo "Triggering Delivery of the helloservice v0.1.1 Artifact (Follow progress in the Bridge)"
keptn trigger delivery \
--project=fulltour \
--service=helloservice \
--image="ghcr.io/podtato-head/podtatoserver:v0.1.1" \
--labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"
