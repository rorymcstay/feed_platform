# project details
export DEPLOYMENT_ROOT=$HOME/app/feed
export SOURCE_DIR=$HOME/dev/feed
export PROJECT_NAME=feed

# sdlc
export IMAGE_REPOSITORY=064106913348.dkr.ecr.us-west-2.amazonaws.com
export GIT_CLONE_URL=ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos

# config database load params
export MONGO_HOST=localhost
export MONGO_PORT=20717
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATAROOT=$HOME/app/feed/mongo

# docker file helpers
alias dc="docker-compose -f $DEPLOYMENT_ROOT/development.yml "
alias dc-up='dc up -d && dc logs --follow'
alias dc-deploy="docker-compose -f $DEPLOYMENT_ROOT/deployment.yml "
alias dc-services="docker-compose -f $DEPLOYMENT_ROOT/services.yml"

source $DEPLOYMENT_ROOT/build/clone_sources.sh

alias gitinfoall="for com in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$com; echo \"$i\"; git status; cd $SOURCE_DIR; done"
alias gitpushall="for com in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$com; echo \"### $i ###\"; git push; cd $SOURCE_DIR; done"

