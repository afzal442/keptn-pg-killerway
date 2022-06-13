#
# IMPORTANT: Killercoda should be able to add this file to the VM but it isn't currently working
# So for now I'll wget it from a private Git in the intro_foreground.sh
# But this is anticipated to be a temporary workaround and as soon as Killercoda works we'll pull everything from this repo
#
echo "#=================================#"
echo "# Please enter Git details now    #"
echo "#=================================#"
read -p 'Git Username: ' GIT_USER
read -p 'Git Token: ' GITHUB_TOKEN
read -p 'Git Repo to be Created (eg. keptndemo): ' GIT_NEW_REPO_NAME
GIT_REPO=https://github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git

echo ""
echo "#=================================#"
echo "         Git Details Set:          "
echo "#=================================#"
echo ""
echo "Git Username: $GIT_USER"
echo "Git Token: $GITHUB_TOKEN"
echo "New Git repo to be created: $GIT_REPO"

echo ""
echo "============================================================="
echo "Made a mistake? Easy. Just click the command again on the left to reset everything."
echo "Everything look good? Proceed with the tutorial..."
echo "============================================================="
