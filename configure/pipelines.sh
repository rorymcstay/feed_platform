mkdir "templates"

while IFS= read -r line; do

        # get tag and name of current line
        OIFS=$IFS
        IFS='=' read -ra image_dets <<< "$line"
        IFS=$OIFS
        export COMPONENT="${image_dets[0]}"
        export IMAGETAG="${image_dets[1]}"
        echo doing populate
        python populate.py codebuild_template.json templates/codebuild_${image_dets[0]}.json
        cat templates/codebuild_${image_dets[0]}.json
        echo aws codebuild create-project --cli-input-json file://templates/codebuild_"${image_dets[0]}".json;
        aws codebuild create-project --cli-input-json file://templates/codebuild_"${image_dets[0]}".json;
        done < $1