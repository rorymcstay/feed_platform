"""
Script to geneate a build.txt file
"""

import json
import os

deploy_dir = os.getenv("DEPLOYMENT_ROOT")
tags = ["name", "version"]
empty_dets = {"versions": [], "commitHash": ""}

def getState(component):
    """
    get the current commit hash of a component

    :param component:
    :return: commit hash
    """
    os.chdir(os.path.join(deploy_dir, component))
    return "string"


if __name__ == '__main__':
    with open(os.path.join(deploy_dir, "manifest.txt")) as file:
        components = [{tag: val for val, tag in zip(line.split("="), tags)} for line in file]
    build = []
    with open(os.path.join(deploy_dir, "stateman.json"), "w") as file:
        manifest = json.loads(file.read())
        services = manifest.get("services")
        for component in components:
            state = getState(component.get("name"))
            dets = services.get("services", {}).get(component.get("name"), empty_dets)
            # check version
            if dets.get("commitHash") == state:
                continue
            if component.get("version") in dets.get("versions"):
                continue
            dets.update({"commitHash": state, "versions": dets.get("versions").append(component.get("version"))})
            services.update({"services": dets})
            build.append("{component}={version}".format(**component))
        manifest.update(services)
        file.truncate()
        file.write(json.dumps(manifest))
    with open(os.path.join(deploy_dir, "build", "manifest.txt"), "w") as file:
        file.truncate()
        file.writelines(build)
