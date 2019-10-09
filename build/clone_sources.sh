export DEPLOYMENT_ROOT=~/app/feed/

clone_sources(){

  while IFS= read -r line; do

        # get tag and name of current line
        OIFS=$IFS
        IFS='=' read -ra image_dets <<< "$line"
        IFS=$OIFS

        echo git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"
        git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${DEPLOYMENT_ROOT}"/"${image_dets[0]}"
        cd "${DEPLOYMENT_ROOT}"/${image_dets[0]} && git checkout "${image_dets[1]}"
        cd "${DEPLOYMENT_ROOT}" || exit
  done < $1
}

clone_source() {
  cd $DEPLOYMENT_ROOT || exit
  if [ "$1" ]; then
    echo git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"$1" "${DEPLOYMENT_ROOT}"/"$1"
    git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"$1" "${DEPLOYMENT_ROOT}"/"$1"
  else
    echo "USAGE: clone_source component-name"
  fi
}

hello() {
  if [ $1 ]; then
     echo  true
     else
       echo false
  fi
}