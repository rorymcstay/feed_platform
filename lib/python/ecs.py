import os
import subprocess
import json
from json.decoder import JSONDecodeError


def promptUserForFile(filename, functor: callable, no_interupt=False):

    if os.path.exists(filename) and not no_interupt:
        print(f'Are you sure you want to overwite this file? {filename}')
        perm = input("Overwrite file [Y/n]: ")
        if perm != "Y":
            return
    functor()

def execute(*args, **kargs):
    print(" ".join(args))
    kargs.update({'PATH': f'{kargs.get("PATH")}:{os.getenv("DEPLOYMENT_ROOT")}/bin'})
    out = ''
    process = subprocess.Popen(args, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, universal_newlines=True)
    with process:
        out = " ".join(process.stdout)
    try:
        d = json.loads(out)
    except JSONDecodeError as ex:
        d = {}
        pass
    print('success')
    print(process.returncode)
    if process.returncode != 0:
        print( "WARNING: ")
    return d

def listNameSpaces():
    namespaces = execute('aws', 'servicediscovery', 'list-namespaces').get('Namespaces')
    return namespaces

def getNamespace(name):
    namespaces = listNameSpaces()
    li = list(filter(lambda namespace: namespace.get('Name') == os.environ['PROJECT_NAME'], namespaces))
    return li[0]

def getServiceRegistries():
    services = execute('aws', 'servicediscovery', 'list-services')

    return services.get('Services')

def getServiceRegistryVal(name, val):
    services = getServiceRegistries()
    print(f' have {",".join(list(map(lambda serv: serv.get("Name"), services)))} registries')
    for i in filter(lambda service: service.get('Name') == name, services):
        return i.get(val)
    return None

def deleteServiceRegistry(name):
    srid = getServiceRegistryVal(name, 'Id')
    if srid is None:
        return
    execute('aws', 'servicediscovery', 'delete-service', '--id', srid)

def createServiceRegistry(name):
    if getServiceRegistryVal(name, 'Arn') is not None:
        return
    ns = getNamespace(name)
    nsid = ns.get('Id')
    service_registry = {
        "Name": name,
        "DnsConfig": {
            "RoutingPolicy": "WEIGHTED",
            "DnsRecords": [
                {
                    "Type": "A",
                    "TTL": 300
                }
            ]
        },
    }
    registry = execute('aws', 'servicediscovery', 'create-service','--namespace-id', nsid, '--cli-input-json', json.dumps(service_registry))

def tearDownService(name):
    execute('aws', 'ecs', 'delete-service', '--service', name, '--cluster', f'{os.environ["PROJECT_NAME"]}-cluster')
    deleteServiceRegistry(name)

