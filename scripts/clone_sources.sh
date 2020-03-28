#!/bin/sh

clone_sources(){

  while IFS= read -r line; do

        # get tag and name of current 
        OIFS=$IFS
        IFS='=' read -ra image_dets <<< "$line"
        IFS=$OIFS

        echo git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${SOURCE_DIR}"/"${image_dets[0]}"
        git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"${image_dets[0]}" "${SOURCE_DIR}"/"${image_dets[0]}"
        cd "${SOURCE_DIR}"/${image_dets[0]} 
        cd "${SOURCE_DIR}" || exit
  done < $DEPLOYMENT_ROOT/etc/component_manifest.txt

}

clone_source() {
  if [ "$1" ]; then
    echo git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"$1" "${SOURCE_DIR}"/"$1"
    git clone "${GIT_CLONE_URL}"/"${PROJECT_NAME}"_"$1" "${SOURCE_DIR}"/"$1"
    cd "$SOURCE_DIR/$1" || exit
  else
    echo "USAGE: clone_source component-name"
  fi
}

export -f clone_source
export -f clone_sources

