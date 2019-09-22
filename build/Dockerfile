FROM aws/codebuild/standard

RUN apk update && \
    apk upgrade && \
    apk add git

ENV IMAGE_REPOSITORY=064106913348.dkr.ecr.us-west-2.amazonaws.com
ENV PROJECT_NAME=feed
ENV GIT_CLONE_URL=ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos

RUN apk add --update bash && rm -rf /var/cache/apk/*

COPY manifest.txt ./
COPY build.sh ./
RUN chmod 700 build.sh

ENTRYPOINT ["bash","./build.sh"]
