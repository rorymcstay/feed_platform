mkdir "templates"



make_build_pipeline(){ # component_name
        export COMPONENT="$1"
        echo doing populate
        populate --file $DEPLOYMENT_ROOT/etc/aws/codebuild_template.json > temp/codebuild.json
        mkdir temp
        cat temp/codebuild.json
        echo aws codebuild create-project --cli-input-json file://$DEPLOYMENT_ROOT/temp/codebuild.json
        echo $(aws codebuild create-project --cli-input-json file://$DEPLOYMENT_ROOT/temp/codebuild.json)
        rm $DEPLOYMENT_ROOT/temp/codebuild.json
        echo $COMPONENT done
}

make_build_pipeline feed-admin
#make_build_pipeline ui-server
#make_build_pipeline nanny 
#make_build_pipeline router
#make_build_pipeline commands
#make_build_pipeline leader
#make_build_pipeline worker
#make_build_pipeline persistence
#make_build_pipeline mapper
#make_build_pipeline summarizer

