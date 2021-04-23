#!/bin/bash
# update the submodules
git submodule init
git submodule update

targetBaseDir=/var/www/virtual/$USER
branch=$(git branch --show-current)
options=
echo $branch
export HUGO_BRANCH=$branch
if [ $branch = "main" ]
then
    targetDir="$targetBaseDir/blog.ad-schmidt.de"
    options="--baseURL https://blog.ad-schmidt.de"
elif [ $branch = "pre-prod" ]
then
    targetDir="$targetBaseDir/pre-prod.blog.ad-schmidt.de"
    options="--baseURL https://pre-prod.blog.ad-schmidt.de --buildDrafts --buildExpired --buildFuture"
else
    echo "Not on branch main or pre-prod. Exiting without deployment" >&2
    exit 1
fi

echo "Branch $branch: Deploying to $targetDir with options '$options'"
mkdir -p $targetDir
HUGO_CACHEDIR=$HOME/tmp hugo $options --cleanDestinationDir --destination $targetDir


