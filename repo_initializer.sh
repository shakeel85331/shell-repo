#!/bin/bash

# sh repo_initializer.sh test-project-1 https://github.com/shakeel85331/movie-info-service.git https://github.com/shakeel85331 TEST-000 plain_springboot shakeel85331 githubtoken

echo "Checking if all the mandatory parameters are provided."
if [ $# -ne 7 ]; then
    echo "Usage: repo_initializer.sh NEW_REPO_NAME URL_FOR_REPO_TO_BE_CLONED GITHUB_UPLOAD_URL JIRA_STORY APP_TYPE"
    echo "APP_TYPE can be one of [plain_springboot, publisher_sprinboot, consumer_springboot]"
    exit 1
fi

#echo "Inputs received : $1 $2 $3 $4 $5 $6 $7"

DEST=$1
CLONE_URL=$2
GITHUB_UPLOAD_URL=$3
JIRA_STORY=$4
BRANCH=$5
USERNAME=$6
PASSWORD=$7


if [ $BRANCH == "plain_springboot" ]; then
  echo "Request is for plain springboot project creation."
elif [ $BRANCH == "publisher_springboot" ]; then
  echo "Request is for publisher springboot project creation."
elif [ $BRANCH == "consumer_springboot" ]; then
  echo "Request is for consumer springboot project creation."
else
  echo "Invalid APP_TYPE $BRANCH provided, exiting..."
  exit 2
fi


echo "Checking if a repo $DEST already exists"
if [ -a $DEST ]; then
    echo "$DEST already exists"
    exit 3
fi

mkdir -p $DEST
cd $DEST

git init
git remote add origin $CLONE_URL
# git config core.sparseCheckout true
# echo "sample-project/" >> .git/info/sparse-checkout
git pull origin $BRANCH


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
mv movie-info-service $DEST

echo "Pushing the new repo $DEST to github"
git init
git add .
git commit -m "$JIRA_STORY : first commit"
git branch -M main
git remote add origin $GITHUB_UPLOAD_URL/$DEST.git
curl -u $USERNAME:$PASSWORD https://github.gapinc.com/api/v3/user/repos -d '{"name":"'$DEST'"}'
git push -u origin main

echo "Successfully created the new git repo for $DEST"

cd ..
rm -rf $DEST


