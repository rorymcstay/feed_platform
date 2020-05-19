#!/bin/sh

source $HOME/venv/bin/activate
source $HOME/feed/etc/profiles/cicd.env

$DEPLOYMENT_ROOT/scripts/kill-update-listener.sh

pip install -r $DEPLOYMENT_ROOT/etc/requirements.txt

python $DEPLOYMENT_ROOT/scripts/update-listener.py & echo $! > $DEPLOYMENT_ROOT/update-listener-pid


