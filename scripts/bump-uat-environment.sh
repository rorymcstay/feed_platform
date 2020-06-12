#!/bin/bash
source $DEPLOYMENT_ROOT/etc/profiles/cicd.env

cd $DEPLOYMENT_ROOT
command_log_file=$DEPLOYMENT_ROOT/tmp/bump-uat-environment.log

git checkout environments 
git fetch 
git pull origin master 

bump_versions --name $1 --version $2 

cat etc/profiles/uat.versions.env 
source $DEPLOYMENT_ROOT/etc/profiles/uat.versions.env
envsubst < $DEPLOYMENT_ROOT/etc/kube/versions-template.yaml > etc/uat.versions.yaml

cat etc/uat.versions.yaml 


helm upgrade uat-feedmachine $DEPLOYMENT_ROOT/etc/kube/feedmachine \
	--namespace uat \
	--values etc/uat.versions.yaml \
	--values etc/kube/feedmachine/values.yaml \
	--values etc/kube/feedmachine/uat-values.yaml 
git add etc/manifest.txt etc/profiles/uat.versions.env etc/uat.versions.yaml 

helm upgrade uat-feedmachine $DEPLOYMENT_ROOT/etc/kube/feedmachine --namespace uat --values etc/uat.versions.yaml --values etc/kube/feedmachine/values.yaml 


git commit -m 'UAT environment upgrade' 

git push 
