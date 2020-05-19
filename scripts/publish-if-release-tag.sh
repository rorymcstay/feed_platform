#!/bin/sh
git clone $GIT_URL git_dir 

cd git_dir || exit

git checkout $CODEBUILD_RESOLVED_SOURCE_VERSION


IMAGE_NAME=$PROJECT_NAME/$COMPONENT
echo "git describe --exact-match --tags $(git log -n1 --pretty='%h')"
tag=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))
echo "Current source tag is '${tag}'"

sem_ver_regex="^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"


IS_RELEASE=1
echo $tag | grep -E -q $sem_ver_regex || IS_RELEASE=0

if [ $IS_RELEASE -eq "1" ]; then
    echo "publishing docker image version $tag";
    $(aws ecr get-login --no-include-email --region us-west-2);_
    docker tag $IMAGE_REPOSITORY/$IMAGE_NAME $IMAGE_REPOSITORY/$IMAGE_NAME:$tag;
    docker push $IMAGE_REPOSITORY/$IMAGE_NAME:$tag;
    curl "http://feedmachine.rorymcstay.com/updatemanager/rolloutImage/$COMPONENT/$tag/7201873fd83683026d53267fd3606471f51fdf68ad1b4da3709d3cf5f8e8f1f1"
    exit;
fi

echo "Not publishing image as $tag"

