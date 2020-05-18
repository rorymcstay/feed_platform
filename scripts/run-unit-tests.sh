#!/bin/bash

docker pull selenium/standalone-chome:3.141.59
docker pull mongo:latest

pip install -r requirements.txt

python -m unittest src.test

