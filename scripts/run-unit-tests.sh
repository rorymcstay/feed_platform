#!/bin/bash
cwd=$pwd
component=. # default to current working director
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
      shift
      echo "Compnent $1 was specified"
      component=`echo $SOURCE_DIR/$1`
      shift
      ;;
    *)
      break
      ;;
  esac
done

cd $component || echo "$component not found"

echo 'Creating test docker network'
docker network create test

echo 'Source test environment'
source $CODEBUILD_SRC_DIR_platform/etc/profiles/dev.env

echo 'installing requirements'
pip install -r requirements.txt || exit 1;

echo "Starting the tests  in $component/src/test ..."
python -m unittest discover $component/src/test -p 'test_*.py' --verbose || exit 1;

cd $cwd
