# project details
export DEPLOYMENT_ROOT=$HOME/app/feed
export SOURCE_DIR=$HOME/dev/feed
export PROJECT_NAME=feed

# sdlc
export DEFAULT_REGION=us-west-2
export IMAGE_REPOSITORY=064106913348.dkr.ecr.us-west-2.amazonaws.com
export GIT_CLONE_URL=ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos

####### LOCAL DEVELOPMEMNT PARAMS #########
# config database load params
export MONGO_HOST=localhost
export MONGO_PORT=20717
export DATABASE_HOST=localhost
export DATABASE_PASS=feeds
export DATABASE_NAME=feeds
export DATABASE_USER=feeds
export DATABASE_PORT=5432
export BROSWER_PORT=6000
export BROWSER_CONTAINER_HOST=localhost
export PERST_HOST=localhost
export SUMMARIZER_HOST=localhost
export PYTHONPATH="$PYTHONPATH:$SOURCE_DIR/utils"
export CONFIG_DATAROOT=$DEPLOYMENT_ROOT/etc/config_data
export LEADER_TEMPLATE=leader

export LOG_LEVEL=DEBUG

alias gitstatus='for i in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$i; echo "### $i ###"; git status;done'
alias sourceversions='for i in $(ls ~/dev/feed); do cd ~/dev/feed/$i && echo  $i=$(git describe --exact-match --tags $(git log -n1 --pretty='%h')) || echo ''; done | grep ='
# docker file helpers
alias dc="docker-compose -f $DEPLOYMENT_ROOT/etc/compose/development.yml "
alias dc-up='dc up -d && dc logs --follow'
alias dc-deploy="docker-compose -f $DEPLOYMENT_ROOT/etc/compose/deployment.yml "
alias dc-services="docker-compose -f $DEPLOYMENT_ROOT/etc/compose/services.yml"

source $DEPLOYMENT_ROOT/scripts/clone_sources.sh

alias gitinfoall="for com in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$com; echo \"$i\"; git status; cd $SOURCE_DIR; done"
alias gitpushall="for com in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$com; echo \"### $i ###\"; git push; cd $SOURCE_DIR; done"

export PATH="$PATH:/$DEPLOYMENT_ROOT/bin"
export PYTHONPATH="$PYTHONPATH:$DEPLOYMENT_ROOT/lib/python"


export WIREGUARD_INTERFACE=10.66.66.3
