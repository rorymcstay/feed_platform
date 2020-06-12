#!/bin/bash
source $DEPLOYMENT_ROOT/etc/profiles/cicd.env

cd $DEPLOYMENT_ROOT
command_log_file=$DEPLOYMENT_ROOT/tmp/bump-uat-environment.log

git checkout environments &> $command_log_file
git fetch &> $command_log_file
git pull origin master &> $command_log_file

bump_versions --name $1 --version $2 &> $command_log_file

cat etc/profiles/uat.versions.env &> $command_log_file
source $DEPLOYMENT_ROOT/etc/profiles/uat.versions.env
envsubst < $DEPLOYMENT_ROOT/etc/kube/versions-template.yaml > etc/uat.versions.yaml

cat etc/uat.versions.yaml &> $command_log_file


git add etc/manifest.txt etc/profiles/uat.versions.env etc/uat.versions.yaml &> $command_log_file

helm upgrade uat-feedmachine $DEPLOYMENT_ROOT/etc/kube/feedmachine --namespace uat --values etc/uat.versions.yaml --values etc/kube/feedmachine/values.yaml &> $command_log_file


git commit -m 'UAT environment upgrade' &> $command_log_file

git push &> $command_log_file
