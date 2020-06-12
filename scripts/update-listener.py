import os
from flask_classy import FlaskView
from flask import Flask
import subprocess
import logging
from feed.engine import ThreadPool

from logging.handlers import SMTPHandler


component_name_overrides = {
    'router': 'routing'
}

secret_key = '7201873fd83683026d53267fd3606471f51fdf68ad1b4da3709d3cf5f8e8f1f1'

newline='\n'


"""
mail_handler = SMTPHandler(
    mailhost='127.0.0.1',
    fromaddr='server-error@example.com',
    toaddrs=['admin@example.com'],
    subject='Application Error'
)
mail_handler.setLevel(logging.ERROR)
mail_handler.setFormatter(logging.Formatter(
    '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
))
if not app.debug:
    app.logger.addHandler(mail_handler)
"""

def execute(command):
    #, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, universal_newlines=True)
    logging.info(f' running {command}')
    with subprocess.Popen(command, bufsize=10, stderr=subprocess.PIPE, stdout=subprocess.PIPE) as command_output:
        for line in command_output.stderr:
            logging.info(f'pid:{command_output.pid}: {str(line, "utf-8").strip(newline)}')
        for line in command_output.stdout:
            logging.info(f'pid:{command_output.pid}: {str(line, "utf-8").strip(newline)}')
        command_output.wait(timeout=30)
        logging.info(f'process {command} has returned with status code {command_output.returncode}')

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
            logging.info(f'Making instance of command runner')
            return CommandRunner()
        else:
            return __instance

    def _rolloutImage(self, name, version):
        command = UpdateManager._updateCommand(get_component_name(name), version)
        logging.info(f'rolling out image version {version} for {name}')
        logging.info(f'Running: {" ".join(command)}')
        subprocess.Popen(command, bufsize=10)
        return 'ok'

    def rolloutImage(self, name, version):
        self.add_task(self._rolloutImage, name, version)
        return 'ok'

    def getCurrentVersions(self, env):
        with open(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/{env}.versions.yaml') as manifest:
            txt = manifest.read()
        return txt

    def promoteToProd(self):
        self.add_task(self._promote)
        return 'ok'

    def _promote(self):
        execute(f'{os.getenv("DEPLOYMENT_ROOT")}/scripts/promote-to-prod.sh &> {os.environ["DEPLOYMENT_ROOT"]}/tmp/ci-scripts.log')
        logging.info(f'doing promotion step')

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
    from logging.config import dictConfig

    dictConfig({
        'version': 1,
        'formatters': {'default': {
            'format': '[%(asctime)s]%(thread)d: %(module)s - %(levelname)s - %(message)s',
        }},
        'handlers': {'wsgi': {
            'class': 'logging.FileHandler',
            'filename': f'{os.getenv("DEPLOYMENT_ROOT")}/tmp/ci.log',
            'formatter': 'default'
        }},
        'root': {
            'level': 'INFO',
            'handlers': ['wsgi']
        }
    })

    app = Flask(__name__)
    UpdateManager.register(app)
    logging.info(app.url_map)
    app.run(host='0.0.0.0', port=5000)
