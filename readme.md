<!--TODO environment variables for hosts/-->

Getting started

1. make the directories 
    
        mkdir $HOME/dev/feed

    This repo should be in $HOME/app/feed

2. then do
    
        ~/app/feed$ source environment.sh
        ~/app/feed$ clone_sources

3. then start the services
    
        ~/app/feed$ dc-services up -d
   Sometimes kafka will fail to come up, re run the same command once again to verify

4. then initialise the mongo database
        
        ~/app/feed$ docker build etc/config_data --tag config_data
        ~/app/feed$ docker run --network compose_default config_data

5. then start the app
    
        dc-deploy up -d # this is version containers from ecr
        dc up  -d # source code built containers from SOURCE_DIR
#Platform Road Map:

## monitoring
https://grafana.com/grafana/dashboards/893

    - monitoring.yml
    - grafana/
    - prometheus/

## services
    - services.yml

## app
    - docker-compose.yml
    - docker.env

## Database initialisation script



