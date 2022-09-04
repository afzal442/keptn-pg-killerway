echo "======================================================="
echo "Add Self-Healing (scaling with Helm) to production"
echo "======================================================="
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
            - name: "deployment"
            - name: "test"
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
            - name: "deployment"
            - name: "test"
            - name: "evaluation"
              properties:
                timeframe: "2m"

        - name: "remediation"
          triggeredOn:
            - event: "production.remediation.finished"
              selector:
                match:
                  evaluation.result: "fail"
          tasks:
            - name: "get-action"
            - name: "action"
            - name: "test"
            - name: "evaluation"
              properties:
                timeframe: "2m"
EOF
git remote set-url origin https://$GIT_USER:$GITHUB_TOKEN@github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git
git config --global user.email "keptn@keptn.sh"
git config --global user.name "Keptn"
git pull
git add -A
git commit -m "add self-healing to production"
git push

echo ""
echo "=============================="
echo "Add Keptn Remediation File"
echo "=============================="
cd ~/$GIT_NEW_REPO_NAME
git checkout --track origin/production
cat << EOF > helloservice/remediation.yaml
apiVersion: spec.keptn.sh/0.1.4
kind: Remediation
metadata:
  name: helloservice-remediation
spec:
  remediations:
    - problemType: http_response_time_seconds_main_page_sum
      actionsOnOpen:
        - action: scale
          name: scale
          description: Scale up
          value: "2"
EOF
git remote set-url origin https://$GIT_USER:$GITHUB_TOKEN@github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git
git config --global user.email "keptn@keptn.sh"
git config --global user.name "Keptn"
git add -A
git commit -m "add remediation file to production"
git push

echo ""
echo "============================================================================================="
echo "Link Remediation to Action (Modify job/config.yaml. Use helm to action the scaling request)"
echo "============================================================================================="
cd ~/$GIT_NEW_REPO_NAME
cat << EOF > helloservice/job/config.yaml
apiVersion: v2
actions:
  - name: "Deploy using helm"
    events:
      - name: "sh.keptn.event.deployment.triggered"
    tasks:
      - name: "Run helm"
        files:
          - /charts
        env:
          - name: IMAGE
            value: "$.data.configurationChange.values.image"
            valueFrom: event
        image: "alpine/helm:3.9.0"
        serviceAccount: "jes-deploy-using-helm"
        cmd: ["helm"]
        args: ["upgrade", "--create-namespace", "--install", "-n", "\$(KEPTN_PROJECT)-\$(KEPTN_STAGE)", "\$(KEPTN_SERVICE)", "/keptn/charts/\$(KEPTN_SERVICE).tgz", "--set", "image=\$(IMAGE)", "--wait"]

  - name: "Run tests using locust"
    events:
      - name: "sh.keptn.event.test.triggered"
    tasks:
      - name: "Run locust"
        files:
          - locust/basic.py
          - locust/locust.conf
        image: "locustio/locust:2.8.6"
        cmd: ["locust"]
        args: ["--config", "/keptn/locust/locust.conf", "-f", "/keptn/locust/basic.py", "--host", "http://\$(KEPTN_SERVICE).\$(KEPTN_PROJECT)-\$(KEPTN_STAGE)", "--only-summary"]

  - name: "Remediation: Scaling with Helm"
    events:
      - name: "sh.keptn.event.action.triggered"
        jsonpath:
          property: "$.data.action.action"
          match: "scale"
    tasks:
      - name: "Scale with Helm"
        files:
          - /charts
        env:
          - name: REPLICA_COUNT
            value: "$.data.action.value"
            valueFrom: event
        image: "alpine/helm:3.9.0"
        serviceAccount: "jes-deploy-using-helm"
        cmd: ["helm"]
        args: ["upgrade", "-n", "\$(KEPTN_PROJECT)-\$(KEPTN_STAGE)", "\$(KEPTN_SERVICE)", "/keptn/charts/\$(KEPTN_SERVICE).tgz", "--set", "replicaCount=\$(REPLICA_COUNT)"]
EOF
git add -A
git commit -m "add remediation action to jes in production"
git push

echo ""
echo "===================================================="
echo " Dummy problem created as remediation_trigger.json"
echo "===================================================="
cd ~
cat <<EOF > remediation_trigger.json
{
  "type": "sh.keptn.event.production.remediation.triggered",
  "specversion": "1.0",
  "source": "https://github.com/keptn/keptn/fake-problem",
  "contenttype": "application/json",
  "data": {
    "project": "fulltour",
    "stage": "production",
    "service": "helloservice",
    "problem": {
      "problemTitle": "http_response_time_seconds_main_page_sum"
    }
  }
}
EOF
