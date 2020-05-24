#!/bin/bash
component=./ # default to current working director
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - run unit tests, downloading necessary docker images"
      echo " "
      echo "$package [options] application [arguments]"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "--kafka                   pull kafka docker"
      echo "--postgres                pull postgres"
      echo "--mongo                   pull mongo"
      echo "--selenium                pull selenium"
      echo "--component               run 'component' test from '\$SOURCE_DIR'"
      exit 0
      ;;
    --mongo)
      shift
      docker pull mongo:latest
      shift
      ;;
    --postgres)
      shift
      docker pull postgres:latest
      shift
      ;;
    --kafka)
      shift
      docker pull confluentinc/cp-kafka:latest
      docker pull confluentinc/cp-zookeeper:latest
      shift
      ;;
    --selenium)
      shift
      docker pull selenium/standalone-chrome:3.141.59
      shift
      ;;
    --component*)
      component=`echo $SOURCE_DIR/$1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done

docker network create test

source $CODEBUILD_SRC_DIR_platform/etc/profiles/dev.env
pip install -r requirements.txt

python -m unittest discover $component/src/test -p 'test_*.py'

