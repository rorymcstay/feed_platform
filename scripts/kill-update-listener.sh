source $HOME/feed/etc/profiles/cicd.env

kill -9 $(cat $DEPLOYMENT_ROOT/update-listener-pid)
