#!/bin/sh

source $HOME/venv/bin/activate
source $HOME/feed/etc/profiles/cicd.env

pip install -r $DEPLOYMENT_ROOT/etc/requirements.txt

python $DEPLOYMENT_ROOT/update-listener.py & echo $! > $DEPLOYMENT_ROOT/update-lister-pid


