#!/usr/bin/env bash

COMPOSE_DIRECTORY=$DEPLOYMENT_ROOT/etc/compose/
export AWS_DEFAULT_REGION=us-west-2


start() {
  echo Starting application
}

configure_cluster() {
  ecs-cli configure --cluster $PROJECT_NAME-cluster \
    --default-launch-type FARGATE \
    --config-name $PROJECT_NAME-cluster-config \
    --region $AWS_DEFAULT_REGION

}

alias ecs_create="ecs-cli compose service create \
    --ecs-params $DEPLOYMENT_ROOT/etc/aws/ecs-params.yml \
    --region $AWS_DEFAULT_REGION \
    --cluster-config $PROJECT_NAME-cluster-config \
    --cluster $PROJECT_NAME-cluster "

alias ecs_command="ecs-cli compose --verbose \
    --project-name $PROJECT_NAME \
    --ecs-params $DEPLOYMENT_ROOT/etc/aws/ecs-params.yml \
    --region $AWS_DEFAULT_REGION \
    --cluster-config $PROJECT_NAME-cluster-config \
    --cluster $PROJECT_NAME-cluster "

alias ecs_services="ecs_command --file $COMPOSE_DIRECTORY/services.yml "
alias ecs_app="ecs_command --file $COMPOSE_DIRECTORY/deployment.yml "


stop() {
  ecs-cli compose --project-name "${PROJECT_NAME}"-cluster \
   --cluster-config "${PROJECT_NAME}"-cluster-config \
   --ecs-profile "${AWS_PROFILE}" \
    --cluster ${PROJECT_NAME}-cluster \
   service down
}

clean_up() {
  ecs-cli down --force\
   --cluster-config ${PROJECT_NAME}-cluster-config \
   --ecs-profile "${AWS_PROFILE}"\
    --cluster ${PROJECT_NAME}-cluster
}

