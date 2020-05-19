#!/bin/bash

secret_name=awsecr-cred
auth_location=$(locate .docker/config.json)

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $IMAGE_REPOSITORY


# out with the old
kubectl delete secrets $secret_name --namespace prod
kubectl delete secrets $secret_name --namespace uat

# in with the new
kubectl create secret generic $secret_name --from-file=.dockerconfigjson=/home/rory/snap/docker/423/.docker/config.json --type=kubernetes.io/dockerconfigjson --namespace prod
kubectl create secret generic $secret_name --from-file=.dockerconfigjson=/home/rory/snap/docker/423/.docker/config.json --type=kubernetes.io/dockerconfigjson --namespace uat

