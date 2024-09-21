#!/bin/bash

# sh repo_initializer.sh test-project-1 https://github.com/shakeel85331 movie-info-service https://github.com/mshakeel-projects TEST-000 plain_springboot shakeel85331 githubtoken

echo "Checking if all the mandatory parameters are provided."
if [ $# -ne 8 ]; then
    echo "Usage: repo_initializer.sh NEW_REPO_NAME URL_FOR_REPO_TO_BE_CLONED GITHUB_UPLOAD_URL JIRA_STORY APP_TYPE"
    echo "APP_TYPE can be one of [plain_springboot, publisher_sprinboot, consumer_springboot]"
    exit 1
fi

DEST=$1
CLONE_URL=$2
CLONE_REPO=$3
GITHUB_UPLOAD_URL=$4
JIRA_STORY=$5
BRANCH=$6
USERNAME=$7
PASSWORD=$8


if [ $BRANCH = "plain_springboot" ]; then
  echo "Request is for plain springboot project creation."
elif [ $BRANCH = "publisher_springboot" ]; then
  echo "Request is for publisher springboot project creation."
elif [ $BRANCH = "consumer_springboot" ]; then
  echo "Request is for consumer springboot project creation."
else
  echo "Invalid APP_TYPE $BRANCH provided, exiting..."
  exit 2
fi


echo "Checking if a repo $DEST already exists"
if [ -a $DEST ]; then
    echo "$DEST already exists"
    rm -rf $DEST
fi

# mkdir -p $DEST
# cd $DEST

# git init
# git remote add origin $CLONE_URL
# git config core.sparseCheckout true
# echo "sample-project/" >> .git/info/sparse-checkout
# git pull origin $BRANCH

CLONE_REPO_URL=$CLONE_URL"/"$CLONE_REPO
echo $CLONE_REPO_URL

USER_PADED_CLONE_REPO_URL=$(echo $CLONE_REPO_URL | sed -e "s/https:\/\//https:\/\/$USERNAME:$PASSWORD@/g")
echo $USER_PADED_CLONE_REPO_URL

git clone $USER_PADED_CLONE_REPO_URL
mv $CLONE_REPO $DEST
cd $DEST
git checkout $BRANCH


#mv sample-project/* .
rm -rf .git

if [ -z "$(find . -mindepth 1 -maxdepth 1)" ]; then
    echo "$DEST Directory is empty, error checking out source code from template project."
    exit 4
else
    echo "$DEST Directory is not empty, source code checked out from template project."
fi

echo "Configuring the cloned repo based on the input."
find . -type f | xargs perl -pi -e 's/#APPNAME#/'$DEST'/g;'
mv franchise-publisher-template-project $DEST

echo "Pushing the new repo $DEST to github"

git config --global user.name "Mohammed Shakeel"
git config --global user.email "shakeel85331@yahoo.co.in"
echo "git username and email setup"

git init
echo "git init done"

git add .
echo "git add done"

git commit -m "$JIRA_STORY : first commit"
echo "git commit done"

git branch -m main
echo "main branch setup done"

git remote add origin $GITHUB_UPLOAD_URL/$DEST
echo "remote setup done"

curl -u $USERNAME:$PASSWORD https://api.github.com/orgs/mshakeel-projects/repos -d '{"name":"'$DEST'"}'
echo "repo created on github"

git push -u origin main
echo "code pushed to origin"

echo "Successfully created the new git repo for $DEST"

cd ..
rm -rf $DEST
echo "local repo deleted on machine"
