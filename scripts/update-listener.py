from flask_classy import FlaskView
from flask import Flask
import subprocess



class UpdateManager(FlaskView):

    @staticmethod
    def _updateCommand(name, version):
        return 'kubectl set image deployment/{name} {name}=064106913348.dkr.ecr.us-west-2.amazonaws.com/feed/{name}:{version}'.format(name=name, version=version).split(' ')

    def rolloutImage(self, name, version):
        command = UpdateManager._updateCommand(name, version)
        subprocess.Popen(command, bufsize=10)
        return 'ok'


if __name__ == '__main__':
    app = Flask('updatelistener')
    UpdateManager.register(app)
    print(app.url_map)
    app.run(host='0.0.0.0', port=5000)
