export IMAGE_REPOSITORY=064106913348.dkr.ecr.us-west-2.amazonaws.com
export PROJECT_NAME=feed
export SOURCE_DIR=/home/emmett/feed/dev/feed

export GIT_CLONE_URL=https://git-codecommit.us-west-2.amazonaws.com/v1/repos

export MONGO_HOST=localhost
export MONGO_PORT=20717
export DEPLOYMENT_ROOT=~/app/feed
export DATABASE_HOST=localhost
export DATABASE_PORT=5432


export DATAROOT=/home/rory/feed_platform/mongo

alias dc="docker-compose -f docker-compose.yml "

alias dc-deploy="docker-compose -f deployment.yml "
alias dc-services="docker-compose -f services.yml"

