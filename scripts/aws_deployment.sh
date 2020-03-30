#!/usr/bin/env bash

COMPOSE_DIRECTORY=$DEPLOYMENT_ROOT/etc/compose/

start() {
  echo Starting application
}

configure_cluster() {
  ecs-cli configure --cluster "${PROJECT_NAME}" \
    --default-launch-type FARGATE \
    --config-name "${PROJECT_NAME}"-cluster-config \
    --region "${AWS_DEFAULT_REGION}"
}

alias ecs_services='ecs-cli compose  --file $COMPOSE_DIRECTORY/services.yml \
    --project-name "${PROJECT_NAME}" \
    --ecs-params $DEPLOYMENT_ROOT/etc/aws/ecs-params.yml \
    --cluster ${PROJECT_NAME} \
    --cluster-config "${PROJECT_NAME}"-cluster-config \
    service '

alias ecs_app='ecs-cli compose  --file $COMPOSE_DIRECTORY/deployment.yml \
    --project-name "${PROJECT_NAME}" \
    --ecs-params $DEPLOYMENT_ROOT/etc/aws/ecs-params.yml \
    --cluster ${PROJECT_NAME} \
    --cluster-config "${PROJECT_NAME}"-cluster-config \
    service '

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

