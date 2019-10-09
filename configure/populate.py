import json
import os
import sys

if sys.argv[1] is None:
    print("usage python populate.py <file_path>")
    sys.exit()

if "_template.json" not in sys.argv[1]:
    print("usage: filename should have _template.json in it")

file = sys.argv[1]


def replaceIterList(lis):
    new = []
    for item in lis:
        if isinstance(item, dict):
            new.append(replaceIter(item))
        elif isinstance(item, list):
            new.append(replaceIterList(item))
        else:
            new.append(str(item).replace("${", "{").format(**os.environ))
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
            new.update({key: dic[key].replace("$", "").format(**os.environ)})
    return new


if __name__ == '__main__':
    with open(file) as fileString:
        fileString = fileString.read()
        dic = json.loads(fileString)
        populated = replaceIter(dic)

    with open(sys.argv[2], 'w') as outfile:
        outfile.write(json.dumps(populated))
