import json
import os
import logging
from pymongo import MongoClient

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
dataroot=os.getenv("DATAROOT", os.getcwd())


log = logging.getLogger(__name__)


def writeCollection(collectionName, database):
    with open(os.path.join(dataroot, f"{database}/{collectionName}")) as file:
        data=json.loads(file.read())
        client[database][collectionName.split(".")[0]].insert_many(data)


if __name__ == '__main__':
    for databaseName in filter(lambda item: "." not in item, os.listdir(f"{dataroot}")):
        for collection in os.listdir(os.path.join(dataroot, databaseName)):
            if ".json" not in collection:
                continue
            print(f"inserting {collection} into {databaseName}")
            writeCollection(database=databaseName, collectionName=collection)
