Getting started

1. make the directories 
    
        mkdir $HOME/dev/feed
    
    This repo should be in $HOME/app/feed
2. then do
    
        ~/app/feed$ source environment.sh
        ~/app/feed$ clone_sources

3. then start the services
    
        ~/app/feed$ dc-services up

4. then initialise the mongo database
        
        ~/app/feed$ docker build config_data --tag config_data
        ~/app/feed$ docker run --network feed_default config_data
        # TODO run the config_data container with the services.yml config
        
5. start the components

        ~/app/feed$ dc up -d nanny ui-server router
        ~/app/feed$ dc-up # this will follow logs allowing you to detatch
   


# Stop Service
NOTE: environment.sh must be ran by source or active before commands can be ran

To stop the feed_ containers run the following command
    dc down 

To stop the backend services run the following command
    dc-services down
Platform Road Map:

# monitoring
https://grafana.com/grafana/dashboards/893
    
    - monitoring.yml
    - grafana/
    - prometheus/
    
# services
    - services.yml

# app
    - docker-compose.yml
    - docker.env

# Database initialisation script


