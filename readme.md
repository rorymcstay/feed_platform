<!--TODO environment variables for hosts/-->

1. login into image repostory

        aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 064106913348.dkr.ecr.us-west-2.amazonaws.com 

2. configure environment

        source etc/profiles/prod.env

3. bring up the new components

        dc-services up -d
        dc up -d

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
1. `sudo apt install wireguard`

        $ umask 077
        $ wg genkey > privatekey

    This will create privatekey on stdout containing a new private key. You can then derive your public key from your private key:

        $ wg pubkey < privatekey > publickey

2. `sudo vim /etc/wireguad/wg0.conf` and paste following contents

        [Interface]
        Address = 10.66.66.<Yours>/24,fd42:42:42::<Yours>/64
        PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE # Add forwarding when VPN is started
        PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE # Remove forwarding when VPN is shutdown
        ListenPort = 51820

        PrivateKey  = <Yours>

        [Peer]
        PublicKey = cz+B47FZc3OYSc8+yNfwaeSislmzxwyAnT4cBsEVgiQ=
        PersistentKeepalive = 15
        AllowedIPs = 10.66.66.1/32, fd42:42:42::1/128
        Endpoint = 18.132.210.40:51820

3. `sudo wg-quick up wg0`
4. `ping 10.66.66.1`
5. Server is now available to gateway on at `10.66.66.<Yours>`.


#Platform Road Map:

## monitoring
https://grafana.com/grafana/dashboards/893

    - monitoring.yml
    - grafana/
    - prometheus/

# Kubernetes

enable storage and helm3
    
    microk8s enable storage
    microk8s enable helm3

add the incubator helm chart repository

    helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
	helm repo add bitnami https://charts.bitnami.com/bitnami

## Configuring certificates for feed-admin and postgresql
feed-admin and postgres are configures to use a secret for there certificates. A base64 encoded string done likes so

	base64 certs/feed-admin/server.key  -w 0

You may use `mkcert` to provision certificates. This signing cert must be then trusted on the gateway host.

The encoded strings are added to the following locations
	1. the values.yaml file (or prod-values.yaml for production) for feed-admin deployment in feedmachine helm chart template
	2. the respective secrets config yaml in etc/kube/certs

## initialise kafka, mongo and postgres

Kafka

	helm install kafka incubator/kafka --namespace services --values etc/kube/services/kafka-values.yaml 	

Mongo

	helm install parameters bitnami/mongodb-sharded --values etc/kube/services/mongo_values.yaml --namespace services

Postgresql

	helm install database bitnami/postgresql --values etc/kube/services/postgres_values.yaml --namespace services

Redis - for authn

	helm install redis bitnami/redis --namespace services 

## regsitrey creds ecr
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
1. on the gateway box, make sure `kubectl` and `helm` are installed, clone the repo and checkout the `environments` branch.
2. make a file containing the contents of the uatfeedmachine (output of `microk8s.config`) kube config at `$HOME/.kube/config`
3. install a virtualenvironment in the home directory
3. `source $HOME/feed/etc/profiles/cicd.env && source $HOME/venv/bin/activate && $HOME/scripts/start-update-listener.py`

# create new mongo and database users manually
1. port for 27017 on uatfeedmachine like

        kubectl port-forward --namespace services svc/parameters-mongodb 27017:27017 --address 192.168.1.96

2. on the client do 
    
        $ mongo mognodb:192.168.1.96:27017

        > use admin
        > db.auth( "root", "<pass>")
        > db.createUser({ user: "uat_feeds", pwd: "uat_feeds_123", roles: [{role: "readWrite", db: "uat_actionChains"}], mechanisms: ["SCRAM-SHA-1"]})
   this must be done for both production and uat users

3. for postgres expose database to outside host, then use pgAdminIII to configure

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

