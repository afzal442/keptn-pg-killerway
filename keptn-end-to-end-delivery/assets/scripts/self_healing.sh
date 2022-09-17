echo "======================================================="
echo "Add Self-Healing (scaling with Helm) to production"
echo "======================================================="
cd ~/$GIT_NEW_REPO_NAME
cp ~/self_healing/shipyard.yaml ~/$GIT_NEW_REPO_NAME/shipyard.yaml

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
cp ~/self_healing/remediation.yaml ~/$GIT_NEW_REPO_NAME/helloservice/remediation.yaml

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
cp ~/self_healing/job/config.yaml ~/$GIT_NEW_REPO_NAME/helloservice/job/config.yaml

git add -A
git commit -m "add remediation action to jes in production"
git push

echo ""
echo "===================================================="
echo " Dummy problem created as remediation_trigger.json"
echo "===================================================="
