#=================================#
# Please enter Git details now    #
#=================================#
read -p 'Git Username: ' GIT_USER
read -p 'Git Token: ' GITHUB_TOKEN
read -p 'Git Repo to be Created (eg. keptndemo): ' GIT_NEW_REPO_NAME
export GIT_REPO=https://github.com/$GIT_USER/$GIT_NEW_REPO_NAME.git

echo ""
echo "Thanks! Git Details are set. Please proceed."
