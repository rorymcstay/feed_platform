FROM postgres
LABEL "Product"="PostgreSQL (SSL enabled)"

# Move database initialisation scripts
COPY init/configure-users.sh /docker-entrypoint-initdb.d/configure-users.sh 

# Copy over the certificates
COPY certs/database-key.pem /var/lib/postgresql/server.key
COPY certs/database.pem /var/lib/postgresql/server.crt

# Apply the correct permissions to the postrges files
RUN chown postgres /var/lib/postgresql/server.key && chmod 600 /var/lib/postgresql/server.key
