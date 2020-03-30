#!/usr/bin/env python3
import argparse
import os
import subprocess
from populate import getDict
import logging as log
from cilogger import filehandler, consolehandler
import json
logging = log.getLogger(__name__)
logging.addHandler(filehandler)
logging.addHandler(consolehandler)

parser = argparse.ArgumentParser()
parser.add_argument('--name', default='')
parser.add_argument('--update', action='store_true', default=False)
parser.add_argument('--update_all', action='store_true', default=False)


def execute(command):
    print(command)
    with subprocess.Popen(command.split(), stderr=subprocess.PIPE, stdout=subprocess.PIPE) as proc:
        for i in str(proc.stderr.read()).split("\n"):
            print(i)
        for i in str(proc.stdout.read()).split("\n"):
            print(i)

def getComponents():
    components = []
    with open(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/manifest.txt', 'r') as manifest:
        for line in manifest:
            component = line.split("=")[0]
            components.append(component)
    return components

def updateBuildProject(name):
    os.environ['COMPONENT'] = name
    config = getDict(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/codebuild_template.json')
    jsonString = "'{}'".format(json.dumps(config))
    jsonString = jsonString.replace(' ', '')
    command = f'aws codebuild update-project --name {name} --cli-input-json {jsonString}'
    logging.info(command)
    execute(command)

def makeBuildProject(name):
    os.environ['COMPONENT'] = name
    config = getDict(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/codebuild_template.json')
    jsonString = "'{}'".format(json.dumps(config))
    jsonString = jsonString.replace(' ', '')
    command = f'aws codebuild create-project --cli-input-json {jsonString}'
    logging.info(command)
    execute(command)

def makePipeline(name):
    os.environ['COMPONENT'] = name
    os.environ['PIPELINE_NAME'] = f'{os.getenv("PROJECT_NAME")}_{name}'
    config = getDict(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/pipeline_template.json')
    jsonString = "'{}'".format(json.dumps(config))
    jsonString = jsonString.replace(' ', '')
    command = f'aws codepipeline create-pipeline --cli-input-json {jsonString}'
    logging.info(command)
    execute(command)

def updatePipeline(name):
    os.environ['COMPONENT'] = name
    os.environ['PIPELINE_NAME'] = f'{os.getenv("PROJECT_NAME")}_{name}'
    config = getDict(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/pipeline_template.json')
    jsonString = "'{}'".format(json.dumps(config))
    jsonString = jsonString.replace(' ', '')
    command = f'aws codepipeline update-pipeline --name {name} --cli-input-json {jsonString}'
    logging.info(command)
    execute(command)


if __name__ == "__main__":
    args = parser.parse_args()
    if args.update_all:
        args.update = True
    toDo = [args.name] if not args.update_all else getComponents()
    for name in toDo:
        print(f'updating {name}')
        if args.update:
            updateBuildProject(name)
            updatePipeline(name)
        else:
            makeBuildProject(name)
            makePipeline(name)

