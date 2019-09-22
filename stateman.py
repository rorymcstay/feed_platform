"""
Script to geneate a build.txt file
"""

import json
import os
import git

deploy_dir = os.getcwd()
tags = ["name", "version"]

def getState(component):
    """
    get the current commit hash of a component

    :param component:
    :return: commit hash
    """
    componentRepo = git.Repo(os.path.join(deploy_dir, component))

    return componentRepo.head.commit.hexsha


if __name__ == '__main__':
    with open(os.path.join(deploy_dir, "manifest.txt")) as file:
        components = [{tag: val.strip() for val, tag in zip(line.split("="), tags)} for line in file]
    build = []
    with open(os.path.join(deploy_dir, "stateman.json"), "r") as file:
        manifest = json.loads(file.read())
        services = manifest.get("services")
        for component in components:
            state = getState(component.get("name"))
            dets = services.get(component.get("name"), {"versions": [], "commitHash": ""})
            # check version
            if dets.get("commitHash") == state:
                continue
            if component.get("version") in dets.get("versions", []):
                continue
            dets.update({"commitHash": state, "versions": dets.get("versions", []) + [component.get("version")]})
            services.update({component.get("name"): dets})
            build.append("{name}={version}".format(**component))
        manifest.update({"services": services})
    with open(os.path.join(deploy_dir, "stateman.json"), "w") as file:
        file.write(json.dumps(manifest))
    with open(os.path.join(deploy_dir, "build", "manifest.txt"), "w") as file:
        file.write("\n".join(build))
