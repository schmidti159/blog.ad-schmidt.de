#!/bin/bash

targetBaseDir=/var/www/virtual/$USER
branch=$(git branch --show-current)
echo $branch
if [ $branch = "main" ]
then
    targetDir="$targetBaseDir/blog.ad-schmidt.de"
elif [ $branch = "pre-prod" ]
then
    targetDir="$targetBaseDir/pre-prod.blog.ad-schmidt.de"
else
    echo "Not on branch main or pre-prod. Exiting without deployment" >&2
    exit 1
fi

echo "Branch $branch: Deploying to $targetDir"
mkdir -p $targetDir
HUGO_CACHEDIR=$HOME/tmp hugo --cleanDestinationDir --destination $targetDir


