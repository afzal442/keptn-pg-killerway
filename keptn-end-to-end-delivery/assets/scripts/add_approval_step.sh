gh repo clone $GIT_REPO
cd ~/$GIT_NEW_REPO_NAME
cp ~/add_approval/shipyard.yaml ~/$GIT_NEW_REPO_NAME/shipyard.yaml

git remote set-url origin https://$GIT_USER:$GITHUB_TOKEN@github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git
git config --global user.email "keptn@keptn.sh"
git config --global user.name "Keptn"
git add -A
git commit -m "add approval step to production"
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
