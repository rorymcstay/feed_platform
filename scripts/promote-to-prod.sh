#!/bin/bash
source $DEPLOYMENT_ROOT/etc/profiles/cicd.env


git checkout environments

git pull origin master


cat etc/profiles/uat.versions.env
source $DEPLOYMENT_ROOT/etc/profiles/uat.versions.env
envsubst < $DEPLOYMENT_ROOT/etc/kube/versions-template.yaml > etc/prod.versions.yaml

SUCCESS=true

git add etc/manifest.txt etc/prod.versions.yaml
helm upgrade feedmachine $DEPLOYMENT_ROOT/etc/kube/feedmachine --namespace prod --values etc/prod.versions.yaml --values etc/kube/feedmachine/prod-values.yaml || SUCCESS=false

if [[ $SUCCESS == "false" ]]; then
    git commit -m 'PROD environment upgrade - FAILURE' && git push
else
    git commit -m 'PROD environment upgrade - SUCCESS' && git push
    cp $DEPLOYMENT_ROOT/etc/manifest.txt $DEPLOYMENT_ROOT/etc/prod-manifest.txt

