source $DEPLOYMENT_ROOT/etc/profiles/cicd.env

cd $DEPLOYMENT_ROOT

git checkout -f environments

git pull origin master

bump_version --name $1 --version $2

source $DEPLOYMENT_ROOT/profiles/uat.versions.env
envsubst < $DEPLOYMENT_ROOT/etc/kube/versions-template.yaml > etc/uat.versions.yaml

git add etc/manifest.txt etc/profiles/uat.version.env etc/uat.versions.yaml



helm upgrade uat-feedmachine $DEPLOYMENT_ROOT/etc/kube/feedmachine --namespace uat --values etc/uat.versions.yaml



git commit -m 'UAT environment upgrade' && git push
