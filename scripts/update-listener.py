from flask_classy import FlaskView



class UpdateManager(FlaskView):

    @staticmethod
    def _updateCommand(name, version)
        return 'kubectl set image deployment/{name} {name}=064106913348.dkr.ecr.us-west-2.amazonaws.com/feed/{name}:{version}'.format(name, version).split(' ')

    def rolloutImage(name, version):
        command = UpdateManager._updateCommand(name, version)
        with subprocess.Popen(command, bufsize=10) as process:
            for line in process:
                logging.info(process)
        return 'ok'


if __name__ == '__main__':
    app = Flask(__name__)
    app.run(host='0.0.0.0', port=5000)
