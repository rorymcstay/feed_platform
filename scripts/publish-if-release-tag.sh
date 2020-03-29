IMAGE_NAME=$PROJECT_NAME/$COMPONENT
echo "git describe --exact-match --tags $(git log -n1 --pretty='%h')"
tag=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))

export IS_RELEASE=1
echo $tag | grep -E -q "^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$" \
    || IS_RELEASE=0

if [ $IS_RELEASE -eq "1" ]; then
    echo "publishing docker image version $tag";
    docker images --all;
    docker tag $IMAGE_REPOSITORY/$IMAGE_NAME $IMAGE_REPOSITORY/$IMAGE_NAME:tag;
    docker push $IMAGE_REPOSITORY/$IMAGE_NAME:$tag;
    exit;
fi

echo "Not publishing image as $tag"

