import json
import os
import sys
from cilogger import consolehandler, filehandler
import logging

logging = logging.getLogger(__name__)
logging.addHandler(consolehandler)
logging.addHandler(filehandler)


class Environment:

    def __init__(self, env_file):

        self.env_vars = self.loadFromFile(env_file)

    def loadFromFile(self, filename):
        env = {}
        with open(filename, 'r') as envfile:
            lines = filter(lambda line: "#" not in line and '=' in line,
                           envfile.read().split("\n"))
            [env.update({line.split("=")[0].strip(): line.split("=")[1].strip()}) for line in lines]
        return env

    def addToEnv(self, env: dict):
        self.env_vars.update(env)

    def addToEnvFromFile(filename):
        update = self.loadFromFile(filename)
        self.env_vars.update(update)

    def replaceEnvVar(self, string):
        """
        out = ''
        replacements = string.split("$")
        for chunk in replacements:
            if "{" not in chunk and "}" not in chunk:
                out += chunk
                continue
            if len(chunk) == 0:
                out += "$"
                continue
            if "CODEBUILD" in chunk:
                out += "$" if chunk != replacements[0] else '' + chunk
                continue
            try:
                addition = chunk.format(**self.env_vars)
                if len(out) == 0:
                    out += "$" + chunk
                else:
                    out += addition
            except KeyError as ex:
                logging.info(f'{ex.args} not found')
                out += "$" + chunk if chunk != replacements[0] else '' + chunk
        """
        try:
            out = string.format(**self.env_vars)
        except KeyError as ex:
            logging.warning(f'not replacing {ex.args}')
            self.env_vars.update({ex.args[0]: '${'+ex.args[0]+'}'})
            return self.replaceEnvVar(string)
        out = out.replace("$", "")
        out = out.replace("{", "${")

        return out



class JsonFile(Environment):

    def __init__(self, file_name):
        super().__init__(file_name)

    def replaceIterList(self, lis):
        new = []
        for item in lis:
            if isinstance(item, dict):
                new.append(self.replaceIter(item))
            elif isinstance(item, list):
                new.append(self.replaceIterList(item))
            elif isinstance(item, str):
                new.append(self.replaceEnvVar(item))
            else:
                new.append(item)
        return new

    def replaceIter(self, dic):
        new = dic
        for key in dic:
            if isinstance(dic[key], dict):
                new.update({key: self.replaceIter(dic[key])})
            elif isinstance(dic[key], list):
                new.update({key: self.replaceIterList(dic[key])})
            elif isinstance(dic[key], str) and "$" in dic[key]:
                new.update({key: self.replaceEnvVar(dic[key])})
            elif isinstance(dic[key], (int, float, bool)):
                new.update({key: dic[key]})
        return new

    def getDict(self, filename):
        with open(filename) as fileString:
            fileString = fileString.read()
            dic = json.loads(fileString)
            populated = self.replaceIter(dic)
        return populated



