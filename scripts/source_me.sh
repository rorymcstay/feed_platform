# project details
export DEPLOYMENT_ROOT=$HOME/app/feed
export SOURCE_DIR=$HOME/dev/feed
export PROJECT_NAME=feed

# sdlc
export DEFAULT_REGION=us-west-2
export GIT_CLONE_URL=ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos


# docker file helpers
alias dc="docker-compose -f ${DEPLOYMENT_COMPOSE} " 
alias dc-services="docker-compose -f ${SERVICE_COMPOSE}" # 

alias gitinfoall="for com in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$com; echo \"$i\"; git status; cd $SOURCE_DIR; done"
alias gitpushall="for com in $(ls $SOURCE_DIR); do cd $SOURCE_DIR/$com; echo \"### $i ###\"; git push; cd $SOURCE_DIR; done"



