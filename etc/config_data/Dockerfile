FROM python:3.6-alpine

RUN mkdir -p /usr/local/mongo

WORKDIR /usr/local/setup/mongo

COPY requirements.txt requirements.txt
COPY forms forms
COPY params params
COPY mapping mapping
COPY initialise.py initialise.py

ENV CONFIG_DATAROOT=/usr/local/setup/mongo
ENV DATABASE="localhost:27017"

# Copying over necessary files

RUN python -m pip install pip
# Installing packages
RUN pip install -r ./requirements.txt

# Entrypoint
CMD ["python", "./initialise.py" ]
#ENTRYPOINT "python initialise.py"
