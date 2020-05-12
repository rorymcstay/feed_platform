# project details
export PROJECT_NAME=feed

# sdlc
export DEFAULT_REGION=us-west-2
export IMAGE_REPOSITORY=064106913348.dkr.ecr.us-west-2.amazonaws.com
export GIT_CLONE_URL=ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos

# docker file helpers
alias dc="docker-compose -f ${DEPLOYMENT_COMPOSE} " 
alias dc-services="docker-compose -f ${SERVICE_COMPOSE} " # 

