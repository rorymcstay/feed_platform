import json
import os
import sys
import logging

if sys.argv[1] is None:
    print("usage python populate.py <file_path> <out_file_name>")
    sys.exit()

if "_template.json" not in sys.argv[1]:
    print("usage: filename should have _template.json in it")

file = sys.argv[1]

def replaceEnvVar(string):
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
        print(json.dumps(new))
    return new

if __name__ == '__main__':
    variables = dict(**os.environ)

    with open(file) as fileString:
        fileString = fileString.read()
        dic = json.loads(fileString)
        populated = replaceIter(dic)
    print(json.dumps(populated))
    with open(sys.argv[2], 'w') as outfile:
        outfile.write(json.dumps(populated))
