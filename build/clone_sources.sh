#bin/sh
DEPLOYMENT_ROOT=$(pwd)
while IFS= read -r line; do

      # get tag and name of current line
      OIFS=$IFS
      IFS='=' read -ra image_dets <<< "$line"
      IFS=$OIFS

      echo git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"
      git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"
      cd "${DEPLOYMENT_ROOT}"/${image_dets[0]} && git checkout "${image_dets[1]}"
      cd "${DEPLOYMENT_ROOT}"
done < $1 
