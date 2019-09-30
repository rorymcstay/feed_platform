FROM python:3.6-alpine

RUN mkdir -p /usr/local/mongo

WORKDIR /usr/local/setup/mongo

COPY requirements.txt requirements.txt
COPY forms forms
COPY params params
COPY initialise.py initialise.py

ENV DATAROOT=/usr/local/setup/mongo
ENV DATABASE="784e3a5d540e:27017"

# Copying over necessary files

RUN python -m pip install pip
# Installing packages
RUN pip install -r ./requirements.txt

# Entrypoint
CMD ["python", "./initialise.py" ]
#ENTRYPOINT "python initialise.py"