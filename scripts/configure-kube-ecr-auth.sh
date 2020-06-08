#!/bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/../etc/profiles/cicd.env

alias kubectl='microk8s.kubectl '
secret_name=awsecr-cred
auth_location=$(locate .docker/config.json | head -1)


echo "Authentication file location: '$auth_location'"

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $IMAGE_REPOSITORY


# out with the old
echo "Deleting '$secret_name' from all environments"
microk8s.kubectl delete secrets $secret_name --namespace prod
microk8s.kubectl delete secrets $secret_name --namespace uat

# in with the new

echo "Creating '$secret_name' from all environments"
echo "microk8s.kubectl create secret generic $secret_name --from-file=$auth_location --type=kubernetes.io/dockerconfigjson --namespace prod"
microk8s.kubectl create secret generic $secret_name --from-file=.dockerconfigjson=$auth_location --type=kubernetes.io/dockerconfigjson --namespace prod
microk8s.kubectl create secret generic $secret_name --from-file=.dockerconfigjson=$auth_location --type=kubernetes.io/dockerconfigjson --namespace uat

