import json
import os
import logging
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError
from time import sleep
mongo_params = {
    "host": os.getenv("DATABASE", "localhost"),
    "username": os.getenv("MONGO_USER", "root"),
    "password": os.getenv("MONGO_PASS", "root"),
    "serverSelectionTimeoutMS": 5
}

client = MongoClient(**mongo_params)

"""
structure of database is as follows

mapping
    forms.json
    values
    param
forms.json
    parameterSchemas
search
    schema
params_stats

params



"""
dataroot=os.getenv("CONFIG_DATAROOT", f'{os.getenv("DEPLOYMENT_ROOT", "/home/rory/app/feed")}/etc/config_data/')
print(dataroot)

log = logging.getLogger(__name__)
log.setLevel("INFO")

def probeMongoDB():
    try:
        cl = client.list_databases()
        log.info(cl)
    except ServerSelectionTimeoutError as ex:
        log.warning(f'server selection timeout with: {mongo_params}')
        return False
    return True

def writeCollection(collectionName, database):
    with open(os.path.join(dataroot, f"{database}/{collectionName}")) as file:
        data=json.loads(file.read())
        client[database][collectionName.split(".")[0]].insert_many(data)


if __name__ == '__main__':
    while not probeMongoDB():
        sleep(10)
    for databaseName in filter(lambda item: "." not in item and 'Dockerfile'!= item , os.listdir(f"{dataroot}")):
        for collection in filter(lambda name: ".json" in name, os.listdir(os.path.join(dataroot, databaseName))):
            log.warning(f"inserting {collection} into {databaseName}")
            writeCollection(database=databaseName, collectionName=collection)
