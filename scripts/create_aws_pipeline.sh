mkdir "templates"



make_build_pipeline(){ # component_name
        export COMPONENT="$1"
        export PIPELINE_NAME=feed_$COMPONENT

        echo doing populate
        mkdir $DEPLOYMENT_ROOT/temp
        populate --file $DEPLOYMENT_ROOT/etc/aws/codebuild_template.json > $DEPLOYMENT_ROOT/temp/codebuild.json
        echo aws codebuild create-project --cli-input-json file://$DEPLOYMENT_ROOT/temp/codebuild.json
        echo $(aws codebuild create-project --cli-input-json file://$DEPLOYMENT_ROOT/temp/codebuild.json)
        populate --file $DEPLOYMENT_ROOT/etc/aws/pipeline_template.json > $DEPLOYMENT_ROOT/temp/pipeline.json 
        echo aws codepipeline create-project --cli-input-json file://$DEPLOYMENT_ROOT/temp/codepipeline.json
        echo $(aws codepipeline create-pipeline --cli-input-json file://$DEPLOYMENT_ROOT/temp/pipeline.json)
        rm -r $DEPLOYMENT_ROOT/temp
        echo $COMPONENT done
}

make_build_pipeline feed-admin
make_build_pipeline ui-server
make_build_pipeline nanny 
make_build_pipeline routing
make_build_pipeline commands
make_build_pipeline leader
make_build_pipeline worker
make_build_pipeline persistence
make_build_pipeline mapper
make_build_pipeline summarizer

