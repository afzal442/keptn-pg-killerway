echo ""
echo "===================================================="
echo " Adding Prometheus SLIs and SLOs to production stage"
echo "===================================================="
cd ~/keptn-job-executor-delivery-poc
keptn add-resource --project=fulltour --service=helloservice --stage=production --resource=prometheus/sli.yaml --resourceUri=prometheus/sli.yaml
keptn add-resource --project=fulltour --service=helloservice --stage=production --resource=slo.yaml --resourceUri=slo.yaml

echo ""
echo "===================================================="
echo " Adding Locust files to production stage            "
echo "===================================================="
cd ~/keptn-job-executor-delivery-poc
keptn add-resource --project=fulltour --service=helloservice --stage=production --resource=./locust/basic.py
keptn add-resource --project=fulltour --service=helloservice --stage=production --resource=./locust/locust.conf

echo ""
echo "===================================================="
echo " Add new test and evaluation tasks to production    "
echo "===================================================="
cd ~/$GIT_NEW_REPO_NAME
cat << EOF > ~/$GIT_NEW_REPO_NAME/shipyard.yaml
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
            - name: "evaluation"
              properties:
                timeframe: "2m"

    - name: "production"
      sequences:
        - name: "delivery"
          triggeredOn:
            - event: "qa.delivery.finished"
          tasks:
            - name: "approval"
              properties:
                pass: "automatic"
                warning: "automatic"
            - name: "je-deployment"
            - name: "je-test"
            - name: "evaluation"
              properties:
                timeframe: "2m"
EOF
git remote set-url origin https://$GIT_USER:$GITHUB_TOKEN@github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git
git config --global user.email "keptn@keptn.sh"
git config --global user.name "Keptn"
git add -A
git commit -m "add load gen and evaluation to production"
git push

echo ""
echo "===================================================="
echo "Trigger another delivery of helloservice v0.1.1     "
echo "===================================================="
keptn trigger delivery \
--project=fulltour \
--service=helloservice \
--image="ghcr.io/podtato-head/podtatoserver:v0.1.1" \
--labels=image="ghcr.io/podtato-head/podtatoserver",version="v0.1.1"
