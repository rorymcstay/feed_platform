get_sources() {
  git clone "${GIT_CLONE_URL}" staging
  cd /"${DEPLOYMENT_ROOT}"/staging || exit
}

build_images() {
  echo building "$image"
  git pull
  docker-compose build
}

set_image_names() {
  while IFS= read -r line; do
      images+=( "$line" )
  done < <( docker-compose config --services )
}

make_repos() {
  for image in "${images[@]}"; do
      aws ecr create-repository --repository-name "$image" --profile "${AWS_PROFILE}" --region us-east-1
  done
}

push_images() {
  for image in "${images[@]}"; do
    echo pushing "$image"
      docker tag "${PROJECT_NAME}_$image" "${IMAGE_REPOSITORY}"/"${PROJECT_NAME}"-"$image":latest
      docker push "${IMAGE_REPOSITORY}"/"${PROJECT_NAME}"-"$image":latest
  done
}
