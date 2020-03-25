# Minio for ARM64 Arch
## What is Minio?
MinIO is High Performance Object Storage released under Apache License v2.0. It is API compatible with Amazon S3 cloud storage service. Using MinIO build high performance infrastructure for machine learning, analytics and application data workloads.

## Docker Container

```
    docker pull kaissfr/minio:arm64
    docker run -p 9000:9000 kaissfr/minio:arm64 server /data
```

To create a MinIO container with persistent storage, you need to map local persistent directories from the host OS to virtual config ~/.minio and export /data directories. To do this, run the below commands

```
    docker run -p 9000:9000 --name minio1 \
               -v /mnt/data:/data \
               kaissfr/minio:arm64 server /data
```

### MinIO Custom Access and Secret Keys

To override MinIO's auto-generated keys, you may pass secret and access keys explicitly as environment variables. MinIO server also allows regular strings as access and secret keys.

```
    docker run -p 9000:9000 --name minio1 \
               -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
               -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
               -v /mnt/data:/data \
               kaissfr/minio:arm64 server /data
```

### Run MinIO Docker as a regular user

Docker provides standardized mechanisms to run docker containers as non-root users.

You can use **--user** to run the container as regular user.

> NOTE: make sure --user has write permission to ${HOME}/data prior to using --user.

```
    docker run -p 9000:9000 \
               --user $(id -u):$(id -g) \
               --name minio1 \
               -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
               -e "MINIO_SECRET_KEY=wJalrXUtnFEMIK7MDENGbPxRfiCYEXAMPLEKEY" \
               -v /mnt/data:/data \
               kaissfr/minio:arm64 server /data
```

### MinIO Custom Access and Secret Keys using Docker secrets

To override MinIO's auto-generated keys, you may pass secret and access keys explicitly by creating access and secret keys as Docker secrets. MinIO server also allows regular strings as access and secret keys.

```
    echo "AKIAIOSFODNN7EXAMPLE" | docker secret create access_key -
    echo "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" | docker secret create secret_key -
```

Create a MinIO service using docker service to read from Docker secrets.

```
docker service create --name="minio-service" --secret="access_key" --secret="secret_key" kaissfr/minio:arm64 server /data
```

### MinIO Custom Access and Secret Key files

To use other secret names follow the instructions above and replace access_key and secret_key with your custom names (e.g. my_secret_key,my_custom_key). Run your service with

```
    docker service create --name="minio-service" \
                   --secret="my_access_key" \
                   --secret="my_secret_key" \
                   --env="MINIO_ACCESS_KEY_FILE=my_access_key" \
                   --env="MINIO_SECRET_KEY_FILE=my_secret_key" \
                   kaissfr/minio:arm64 server /data
```

## Retrieving Container ID

To use Docker commands on a specific container, you need to know the Container ID for that container. To get the Container ID, run

```
     docker ps -a
```

**-a** flag makes sure you get all the containers (Created, Running, Exited). Then identify the Container ID from the output.

## Starting and Stopping Containers

To start a stopped container, you can use the docker start command.

```
    docker start <container_id>
```

To stop a running container, you can use the docker stop command.

```
    docker stop <container_id>
```

## MinIO container logs

To access MinIO logs, you can use the docker logs command.

```
    docker logs <container_id>
```

## Monitor MinIO Docker Container

To monitor the resources used by MinIO container, you can use the docker stats command.

```
    docker stats <container_id>
```

## Allow port access for Firewalls

By default MinIO uses the port 9000 to listen for incoming connections. If your platform blocks the port by default, you may need to enable access to the port.

### iptables

For hosts with iptables enabled, you can use iptables command to enable all traffic coming to specific ports. Use below command to allow access to port 9000

```
    iptables -A INPUT -p tcp --dport 9000 -j ACCEPT
    service iptables restart
```

Below command enables all incoming traffic to ports ranging from 9000 to 9010.

```
    iptables -A INPUT -p tcp --dport 9000:9010 -j ACCEPT
    service iptables restart
```

### ufw

For hosts with ufw enabled , you can use ufw command to allow traffic to specific ports. Use below command to allow access to port 9000

```
    ufw allow 9000
```

Below command enables all incoming traffic to ports ranging from 9000 to 9010.

```
    ufw allow 9000:9010/tcp
```

### firewall-cmd

For hosts with firewall-cmd enabled, you can use firewall-cmd command to allow traffic to specific ports. Use below commands to allow access to port 9000

```
    firewall-cmd --get-active-zones
```

This command gets the active zone(s). Now, apply port rules to the relevant zones returned above. For example if the zone is public, use

```
    firewall-cmd --zone=public --add-port=9000/tcp --permanent
```

Note that permanent makes sure the rules are persistent across firewall start, restart or reload. Finally reload the firewall for changes to take effect.

```
    firewall-cmd --reload
```