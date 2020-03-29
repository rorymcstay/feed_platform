
echo "git describe --exact-match --tags $(git log -n1 --pretty='%h')"
tag=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))

export IS_RELEASE=1
echo $tag | grep -E -q "^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$" \
    || IS_RELEASE=0

if [ $IS_RELEASE -eq "1" ]; then
    echo "publishing docker image version $tag" 
    docker tag $IMAGE_REPO_NAME:$tag $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:tag;
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$tag;
    exit;
fi

echo "Not publishing image as $tag"

