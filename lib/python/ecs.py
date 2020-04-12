import os
import subprocess
import json
from json.decoder import JSONDecodeError
import time

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

def getManifest():
    with open(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/manifest.txt') as manif:
        manifest = {line.split("=")[0].strip(): line.split("=")[1].strip() for line in filter(lambda ln: "=" in ln,  manif.read().split("\n"))}
    return manifest

def loadEnvFile(filename):
    with open(filename) as env_file:
        env = [{"name": line.split("=")[0].strip(), "value": line.split("=")[1].strip()} for line in filter(lambda ln: "=" in ln, env_file.read().split("\n"))]
    return env

def updateTaskDefinition(name):
    cluster_name = f'{os.environ["PROJECT_NAME"]}-cluster'
    temp_dir = f'{os.environ["DEPLOYMENT_ROOT"]}/tmp'
    temp_task_file = f'{temp_dir}/{name}-task.json'
    ecs_task_location = f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/ecs/tasks'
    ecs_task_file_template = f'{ecs_task_location}/{name}-task.template.json'
    taskDefinition = execute('aws', 'ecs', 'register-task-definition', '--cli-input-json', f'file://{temp_task_file}', **os.environ)
    update_service_args = ['aws', 'ecs', 'update-service', '--service', name,  '--cluster', cluster_name]
    print(taskDefinition)
    task_definition_arn = taskDefinition.get('taskDefinition').get('taskDefinitionArn')
    return task_definition_arn

def setupSupportingServices(name):
    temp_dir = f'{os.environ["DEPLOYMENT_ROOT"]}/tmp'
    env = loadEnvFile(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/ecs/envs/supporting-services.env')
    env = ",".join(map(lambda env_var: f'{env_var.get("name")}={env_var.get("value")}', env))
    supporting_services = execute('populate', '--file', f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/ecs/tasks/supporting-task.template.json', '--env-list', env )
    print(supporting_services)
    manifest = getManifest()
    for container in supporting_services.get("containerDefinitions"):
        version = manifest.get(container.get("name"))
        container["image"] = container.get('image').replace("$", "").format(COMPONENT_VERSION=version)
        for portMapping in container.get("portMappings", []):
            portMapping["containerPort"] = int(portMapping.get("containerPort"))
            portMapping["hostPort"] = int(portMapping.get("hostPort"))

    for container in filter(lambda cont: 'mongo' != cont.get('name'), supporting_services.get("containerDefinitions")):
        container["environment"] = loadEnvFile(f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/ecs/envs/supporting-services.env')
    with open(f'{temp_dir}/supporting-task.json', 'w') as task_file:
        task_file.write(json.dumps(supporting_services, indent=4))

    taskDefinitionArn = updateTaskDefinition('supporting')

    serviceRegistries = getServiceRegistries()
    if len(list(filter(lambda item: item.get('name') == 'supporting-service', serviceRegistries))) == 0:
        createServiceRegistry('supporting-service')
        time.sleep(3)
    arn = getServiceRegistryVal('supporting-service', 'Arn')
    print (arn)

    execute('populate', '--file', f'{os.environ["DEPLOYMENT_ROOT"]}/etc/aws/ecs/services/supporting-service.template.json', '--env-list',f'SERVICE_REGISTRY_ARN={arn},TASK_DEFINITION={taskDefinitionArn.split("/")[-1]}', '--outfile', f'{temp_dir}/supporting-service.json')
    service_list = execute('aws', 'ecs', 'list-services', '--cluster', 'feed-cluster')
    if not any("supporting-service" in arn for arn in  service_list.get("serviceArns")):
        execute('aws', 'ecs', 'create-service', '--cli-input-json', f'file://{temp_dir}/supporting-service.json')
    execute('aws', 'ecs', 'update-service', '--cluster', f'{os.environ["PROJECT_NAME"]}-cluster','--service', 'supporting-service', '--task-definition',taskDefinitionArn, '--desired-count' ,'0')

