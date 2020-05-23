#!/bin/bash

docker pull selenium/standalone-chrome:3.141.59
docker pull mongo:latest
docker pull postgres:latest

docker network create test

docker run mongo -d

source $CODEBUILD_SRC_DIR_platform/etc/profiles/dev.env
pip install -r requirements.txt

python -m unittest discover src/test -p 'test_*.py'

