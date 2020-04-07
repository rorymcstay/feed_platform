import json
import os
import sys
import logging





def replaceEnvVar(string):
    if "CODEBUILD" in string:
        return string
    try:
        replacement = string.replace("$", "").format(**os.environ)
    except KeyError as ex:
        logging.info(f'{ex.args} not found')
        return string
    if replacement==string.replace("$", ""):
        logging.info("Error replacing {}".format(string))
        return string
    if replacement == 'true':
        return True
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
        jsonString = json.dumps(jsonString, indent=4)
    if outfile == '':
        print(jsonString)
    else:
        with open(outfile, 'w+') as out:
            out.write(jsonString)

