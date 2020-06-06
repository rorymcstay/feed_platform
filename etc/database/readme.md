Contains scripts for database initialisation. To use in a container,
mount to volume as

    myapp-postgresql:
    image: postgres:9.6.2
    volumes:
        - ../docker-postgresql-multiple-databases:/docker-entrypoint-initdb.d
    environment:
        - POSTGRES_MULTIPLE_DATABASES=db1,db2
        - POSTGRES_USER=myapp
        - POSTGRES_PASSWORD=


taken from: https://github.com/mrts/docker-postgresql-multiple-databases
