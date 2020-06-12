#!/bin/bash
source $DEPLOYMENT_ROOT/etc/profiles/cicd.env


command_log_file=$DEPLOYMENT_ROOT/tmp/promote-to-prod.log

git checkout environments

git pull origin master


cat etc/profiles/uat.versions.env &> $command_log_file
source $DEPLOYMENT_ROOT/etc/profiles/uat.versions.env 
envsubst < $DEPLOYMENT_ROOT/etc/kube/versions-template.yaml > etc/prod.versions.yaml 

SUCCESS=true

helm upgrade feedmachine $DEPLOYMENT_ROOT/etc/kube/feedmachine --namespace prod --values etc/prod.versions.yaml --values etc/kube/feedmachine/prod-values.yaml &> $command_log_file || SUCCESS=false

cp $DEPLOYMENT_ROOT/etc/manifest.txt $DEPLOYMENT_ROOT/etc/prod-manifest.txt
git add etc/prod.versions.yaml etc/prod-manifest.txt &> $command_log_file

if [[ $SUCCESS == "false" ]]; then
    git commit -m 'PROD environment upgrade - FAILURE' &> $command_log_file
    git push &> $command_log_file
else
    git commit -m 'PROD environment upgrade - SUCCESS ' &> $command_log_file
    git push &> $command_log_file

    echo success &> $command_log_file
fi

