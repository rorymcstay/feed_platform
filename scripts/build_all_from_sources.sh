#!/bin/sh

DEPLOYMENT_ROOT=$(pwd)

make_repos() {
   while IFS= read -r line; do
      OIFS=$IFS
      image_dets=[]
      IFS='=' read -ra image_dets <<< "$line"
      IFS=$OIFS
      echo "${image_dets[0]}"
      aws ecr create-repository --repository-name "${PROJECT_NAME}"/"${image_dets[0]}" --profile "${AWS_PROFILE}" --region us-west-2
   done < /"${DEPLOYMENT_ROOT}"/manifest.txt
}
:
build_and_push_images() {
  while IFS= read -r line; do

      # get tag and name of current line
      OIFS=$IFS
      IFS='=' read -ra image_dets <<< "$line"
      IFS=$OIFS

      echo git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"
      git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"
      cd "${DEPLOYMENT_ROOT}"/${image_dets[0]} && git checkout "${image_dets[1]}"
      cd "${DEPLOYMENT_ROOT}"

      docker build "${DEPLOYMENT_ROOT}"/"${image_dets[0]}" --tag "${PROJECT_NAME}"/"${image_dets[0]}":"${image_dets[1]}"
      docker tag "${PROJECT_NAME}"/"${image_dets[0]}":"${image_dets[1]}" "${IMAGE_REPOSITORY}"/${PROJECT_NAME}/"${image_dets[0]}:${image_dets[1]}"
      echo pushing "${image_dets[0]}:${image_dets[1]}"
      docker push "${IMAGE_REPOSITORY}"/${PROJECT_NAME}/"${image_dets[0]}:${image_dets[1]}"
      rm -rf "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"

   done < /"${DEPLOYMENT_ROOT}"/manifest.txt
}
