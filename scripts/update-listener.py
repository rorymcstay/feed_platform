import os
from flask_classy import FlaskView
from flask import Flask
import subprocess
import logging
from feed.engine import ThreadPool

fh = logging.FileHandler('ci.log')
fh.setLevel('DEBUG')
formatter = logging.Formatter('%(asctime)s: %(name)s - %(level)s - %s(message)')
fh.setFormatter(formatter)

logger = logging.getLogger(__name__)
logger.addHandler(fh)

component_name_overrides = {
    'routing': 'router'
}

secret_key = '7201873fd83683026d53267fd3606471f51fdf68ad1b4da3709d3cf5f8e8f1f1'

def execute(command):
    #, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, universal_newlines=True)
    with subprocess.Popen(command, busize=10) as pro:
        for line in pro.stderr:
            logger.info(line)

class CommandRunner(ThreadPool):
    __instance = None
    def __init__(self):
        if self.__instance is None:
            super().__init__(1)
            self.__instance = self
        else:
            pass

    @staticmethod
    def instance():
        if CommandRunner.__instance is None:
            logger.info(f'Making instance of command runner')
            return CommandRunner()
        else:
            return __instance

    def _rolloutImage(self, name, version):
        command = UpdateManager._updateCommand(get_component_name(name), version)
        logger.info(f'rolling out image version {version} for {name}')
        logger.info(f'Running: {" ".join(command)}')
        subprocess.Popen(command, bufsize=10)
        return 'ok'

    def rolloutImage(self, name, version):
        self.add_task(self._rolloutImage, name, version)
        return 'ok'

    def promoteToProd(self):
        self.add_task(self._promote)
        return 'ok'

    def _promote(self):
        execute(f'{os.getenv("DEPLOYMENT_ROOT")}/scripts/promote-to-prod.sh')
        logger.info(f'doing promotion step')

def get_component_name(name):
    return component_name_overrides.get(name, name)

class UpdateManager(FlaskView):

    @staticmethod
    def _updateCommand(name, version):
        #'kubectl set image deployment/{name} {name}=064106913348.dkr.ecr.us-west-2.amazonaws.com/feed/{name}:{version}'.format(name=name, version=version).split(' ')
        #f'helm upgrade uat-feedmachine {os.getenv("DEPLOYMENT_ROOT")}/etc/kube/feedmachine --set {veridentifier}=feed/{name}:{version} --namespace uat'.split(' ')
        return f'{os.getenv("DEPLOYMENT_ROOT")}/scripts/bump-uat-environment.sh {name} {version}'.split(" ")

    def rolloutImage(self, name, version, key):
        if key != secret_key:
            return 'invalid secret'
        logging.info(f'request to rollout image {name}:{version}')
        CommandRunner.instance().rolloutImage(name, version)
        return 'ok'

    def promoteToProd(self, key):
        if key != secret_key:
            return 'invalid secret'
        CommandRunner.instance().promoteToProd()
        return 'ok'


if __name__ == '__main__':
    app = Flask('updatelistener')
    UpdateManager.register(app)
    print(app.url_map)
    app.run(host='0.0.0.0', port=5000)
