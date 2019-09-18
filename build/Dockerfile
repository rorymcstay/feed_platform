FROM python:alpine

ARG CLI_VERSION=1.16.236
ARG ssh_prv_key
ARG ssh_pub_key
ARG config
ARG aws_config

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh
#    ssh-keyscan git-codecommit.us-west-2.amazonaws.com > /root/.ssh/known_hosts


RUN apk -uv add --no-cache groff jq less && \
    pip install --no-cache-dir awscli==$CLI_VERSION

RUN apk update && \
    apk upgrade && \
    apk add git


# Add the keys and set permissions
RUN mkdir /root/.aws
RUN echo "$ssh_prv_key" > /root/.ssh/rory && \
    echo "$ssh_pub_key" > /root/.ssh/rory.pub && \
    echo "$config" > /root/.ssh/config && \
    echo "$aws_config" > /root/.aws/credentials && \
    chmod 600 /root/.ssh/rory && \
    chmod 600 /root/.ssh/rory.pub

RUN apk add --no-cache openssh

WORKDIR /aws

ENV IMAGE_REPOSITORY=064106913348.dkr.ecr.us-west-2.amazonaws.com
ENV PROJECT_NAME=feed
ENV GIT_CLONE_URL=ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos

RUN apk add --update bash && rm -rf /var/cache/apk/*

COPY manifest.txt ./
COPY build.sh ./
RUN chmod 700 build.sh

ENTRYPOINT ["bash","./build.sh"]
