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

## Configuring certificates for feed-admin and postgresql
feed-admin and postgres are configures to use a secret for there certificates. A base64 encoded string done likes so

	base64 certs/feed-admin/server.key  -w 0

You may use ```mkcert``` to provision certificates. This signing cert must be then trusted on the gateway host.

The encoded strings are added to the following locations
	1. the values.yaml file (or prod-values.yaml for production) for feed-admin deployment in feedmachine helm chart template
	2. the respective secrets config yaml in etc/kube/certs

## initialise kafka, mongo and postgres
# add the bitnami repos
	helm repo add bitnami https://charts.bitnami.com/bitnami
# Kafka
	helm install kafka incubator/kafka --namespace services --values etc/kube/services/kafka-values.yaml 	
# Mongo
	helm install bitnami/mongodb-sharded --values etc/kube/services/mongo_values.yaml --namespace services
# Postgresql
	helm install bitnami/postgresql --values etc/kube/services/postgres_values.yaml --namespace services
# Redis - for authn

	rory@uatfeedmachine:~$ helm install redis bitnami/redis --namespace services 



# regsitrey creds ecr
This is not working, there is a manual script work around in scripts.
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

# create new mongo user
1. port for 27017 on uatfeedmachine like
    
       kubectl port-forward --namespace services svc/parameters-mongodb 27017:27017 --address 192.168.1.96
2. on the client do 
    
        $ mongo mognodb:192.168.1.96:27017

        > use admin
        > db.auth( "root", "<pass>")
        > db.createUser({ user: "uat_feeds", pwd: "uat_feeds_123", roles: [{role: "readWrite", db: "uat_actionChains"}], mechanisms: ["SCRAM-SHA-1"]})
   this must be done for both production and uat users

# expose database to outside host
	
	kubectl port-forward --address 192.168.1.96 --namespace services svc/database-postgresql 5432:5432

# Setup monitoring
	rory@uatfeedmachine:~/feed$ helm install grafana bitnami/grafana --namespace monitoring
	rory@uatfeedmachine:~/feed$ kubectl port-forward svc/grafana 3000:3000 --address 192.168.1.96 --namespace monitoring &

	rory@uatfeedmachine:~/feed $ helm install prometheus bitnami/prometheus-operator --namespace monitoring


# Configuring host
	
	microk8sk, enable helm3, 

	install wireguard

# Configuring wireguard

	$ umask 077
	$ wg genkey > privatekey

	This will create privatekey on stdout containing a new private key.

	You can then derive your public key from your private key:

	$ wg pubkey < privatekey > publickey

	make the wirgeuard

		[Interface]
		Address = 10.66.66.<Yourbit>/24,fd42:42:42::<theirbit>/64
		PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE # Add forwarding when VPN is started
		PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE # Remove forwarding when VPN is shutdown
		ListenPort = 51820
		PrivateKey  = IGyQikKxUWh4TzIES+NNLl+dUOnnGlUGr8oCtdiMpFg=

		[Peer]
		PublicKey = u/YJL4XOA2LWkku2hzwPbkU55fmoSJDgvzMj2+mgtxY=
		AllowedIPs = 10.66.66.2/32, fd42:42:42::2/128
		PersistentKeepalive = 15

		[Peer]
		PublicKey = 3w//zU+tBLr7wTwGDpymEY1sdDizh5iQ/UR+a8HpUXc=
		AllowedIPs = 10.66.66.3/32, fd42:42:42::3/128
		PersistentKeepalive = 15

		[Peer]
		PublicKey = E6ZINyNengLVpcV3zUo72ZJRMTYpCfzQZZitJ9bGMUQ=
		AllowedIPs = 10.66.66.1/32, fd42:42:42::4/128
		PersistentKeepalive = 15

