#!/usr/bin/env bash

start() {
  echo Starting application
}

configure_cluster() {
  ecs-cli configure --cluster "${PROJECT_NAME}"-cluster\
    --default-launch-type EC2\
    --config-name "${PROJECT_NAME}"-cluster-config\
    --region "${AWS_DEFAULT_REGION}"

  ecs-cli up --keypair id_rsa \
   --create-log-groups\
   --capability-iam \
   --size 2 \
   --instance-type t2.medium \
   --cluster-config ec2-tutorial \
   --ecs-profile "${AWS_PROFILE}"
}

start_external_services() {
  ecs-cli compose  --file ./docker-services.yml \
    --create-log-groups\
    --project-name "${PROJECT_NAME}"-cluster \
    --ecs-params ./loader-config.yml \
    --cluster-config "${PROJECT_NAME}"-cluster-config \
    service create
}

start_application() {
  ecs-cli compose --project-name "${PROJECT_NAME}"-cluster \
    --ecs-params ./loader-config.yml \
    --cluster-config "${PROJECT_NAME}"-cluster-config \
    service create
}

stop() {
  ecs-cli compose --project-name "${PROJECT_NAME}"-cluster\
   --cluster-config "${PROJECT_NAME}"-cluster-config\
   --ecs-profile "${AWS_PROFILE}"\
   service down
}

clean_up() {
  ecs-cli down --force\
   --cluster-config tutorial\
   --ecs-profile "${AWS_PROFILE}"
}

