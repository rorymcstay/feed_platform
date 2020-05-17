<!--TODO environment variables for hosts/-->

# Release to feedmachine.rorymcstay.com
1. makesure that you are set up as a peer in wireguard on feedmachine host, and it is configured on your local

        [Interface]
        PrivateKey = <your-private-key>
        Address = 10.66.66.<yours>/24,fd42:42:42::<yours>/64

        [Peer]
        PublicKey = <feedmachine-publick-key>
        Endpoint = 54.245.155.40:51820
        AllowedIPs = 10.66.66.2/32,fd42:42:42::2/128
 
2. go there
    
        ssh 10.66.66.2
        cd feed

3. update feed_platform if needed

        git pull

4. login into image repostory

        aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 064106913348.dkr.ecr.us-west-2.amazonaws.com 

5. configure environment

        source etc/profiles/prod.env

6. bring up the new components

        dc-services up -d
        dc up -d

7. restart the feed-admin to re-establish connection
    
        dc restart feed-admin

8. ping the gateway to establish connection with internet

        ping 10.66.66.1

# Local release
Conduct the above steps without pinging or sshing to things

# Development

1. make the directories 
    
        mkdir $HOME/dev/feed # SOURCE_DIR

    This repo should be in 
        
        $HOME/app/feed

2. then clone the componets to build locally into `SOURCE_DIR` (there are scripts in `scripts`, use at your own risk). If
    not building all from sources, update `etc/profile/manifest.env` and then
        
        source etc/profile/dev.env
        dc-services up -d               # sometimes kafka wont come up, re run the same command once again to verify
        docker-compose -f etc/profile/deployment.yml  # initially start everything from versioned images. Checkout a version of this branch to get a deployment version

3. you may then do `dc up -d <component>` (this isn't actually true you would need everything pulled down).

3. then start the services
    
        ~/app/feed$ dc-services up -d

# wireguard installation

#Platform Road Map:

## monitoring
https://grafana.com/grafana/dashboards/893

    - monitoring.yml
    - grafana/
    - prometheus/

## Database initialisation script


# Kubernetes

## initialise kafka, mongo and postgres

1. kafka

	

#https://hub.kubeapps.com/charts/incubator/kafka
# Configuring a Kafka cluster using helm
	rory@uatfeedmachine:~/feed/etc/kube$ helm init
	Creating /home/rory/.helm 
	Creating /home/rory/.helm/repository 
	rory@uatfeedmachine:~/feed/etc/kube$ helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
	"incubator" has been added to your repositories
	rory@uatfeedmachine:~/feed/etc/kube$ helm install --name my-kafka incubator/kafka
# Kafka
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install bitnami/kafka
# Mongo
helm install bitnami/mongodb-sharded
# Postgresql
helm install bitnami/postgresql


# regsitrey creds ecr
helm install --name registry-creds --set ecr.enabled=true --set-string ecr.awsAccessKeyId="AKIAQ53IR3ZCMEGY2FEF" \
--set-string ecr.awsSecretAccessKey="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" --set-string ecr.awsAccount="064106913348" --set-string ecr.awsRegion="us-west-2" --set-string ecr.awsAssumeRole="arn:aws:iam::064106913348:role/uatfeedmachine" \
kir4h/registry-creds


kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/home/rory/snap/docker/423/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson

enable storgae classes in microk8s

microk8s enable <add-on> (storage)


# automatioc image rollout endpoint
on the gateway box
1. install pip
2. install flask, flask_classy
3. ```pyton3 scripts/update-listener.py &``` run the listener endpoint in the background


