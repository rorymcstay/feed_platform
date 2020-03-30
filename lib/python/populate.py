import json
import os
import sys
import logging





def replaceEnvVar(string):
    if "CODEBUILD" in string:
        return string
    replacement = string.replace("$", "").format(**os.environ)
    if replacement==string:
        logging.info("Error replacing {}".format(string))
    return replacement


def replaceIterList(lis):
    new = []
    for item in lis:
        if isinstance(item, dict):
            new.append(replaceIter(item))
        elif isinstance(item, list):
            new.append(replaceIterList(item))
        else:
            new.append(replaceEnvVar(str(item)))
    return new


def replaceIter(dic):
    new = dic
    for key in dic:
        if isinstance(dic[key], dict):
            new.update({key: replaceIter(dic[key])})
            continue
        if isinstance(dic[key], list):
            new.update({key: replaceIterList(dic[key])})
        if isinstance(dic[key], str) and "$" in dic[key]:
            new.update({key: replaceEnvVar(dic[key])})
    return new

def getDict(filename):
    variables = dict(**os.environ)
    with open(filename) as fileString:
        fileString = fileString.read()
        dic = json.loads(fileString)
        populated = replaceIter(dic)
    return populated

def populate(filename, escaped, outfile):
    populated = getDict(filename)
    jsonString = json.dumps(populated)
    if escaped:
        jsonString = json.dumps(jsonString)
    if outfile == '':
        print(jsonString)
    else:
        with open(outfile, 'w') as out:
            out.write(jsonString)

