# Basic

## Docker registry

- Consists of repositories
- A repository contains images
- Download images:
  - `docker pull <registry>/repo/name:tag`
  - `docker pull alpine`
- Meta-inf is stored in /var/lib/docker
  - in VM for Windows or Mac:
    - `docker run -it --privileged --pid=host justincormack/nsenter1`
    - `ls /var/lib/docker`

### Local Docker Registry

- `docker run -d -p 5001:5000 --restart always --name registry registry:latest`
- `docker ps | grep registry`
- Publish image
  - `docker pull alpine`
  - `docker tag alpine localhost:5001/alpine`
  - `docker push localhost:5001/alpine`
- Check image
  - `docker image rm localhost:5001/alpine`
  - `docker pull localhost:5001/alpine`
  - `docker run -it localhost:5001/alpine sh`

## Images

- `docker images`
- `docker image inspect postgres`

##  Containers

- List:
  - `docker ps` - all RUNNING containers
  - `docker ps -a` - all containers
- Create:
  - `docker create alpine`
    - `docker create --name alpine alpine` - will exit
    - `docker create --name alpine alpine sh` - will exit as bash finished its work
    - `docker create --name alpine alpine sleep 60` - will NOT exit for 1 min
- Inspect
  - `docker inspect alpine`
- Start
  - `docker start alpine`
- Exec:
  - run a command in a running container
  - `docker run -d -e POSTGRES_PASSWORD=postgres --name postgres postgres`
  - `docker exec postgres ls` - run a command within a container and exit
    - `docker exec postgres touch test.txt`
  - `docker exec postgres bash` - will exit as bash finishes
    - `docker exec -i postgres bash` - will NOT exit as interactive mode is used
      - option -d is not necessary!!!
      - `ls`
    - `docker exec -it postgres bash` - terminal (TTY) added
- Run
  - will be connected to standard input/output
  - `docker run -e POSTGRES_PASSWORD=postgres --name postgres postgres`
    - `docker run -d -e POSTGRES_PASSWORD=postgres --name postgres postgres` - detached mode with no standard input/output
    - `docker run --name alpine alpine sh`
      - `docker run -it --name alpine alpine sh`
- Logs
  - `docker logs postgres`
- Stop:
  - `docker stop alpine`
  - `docker kill alpine`
- Remove
- `docker rm alpine` - delete a container

##  Copy files

- `docker run -it --name alpine alpine sh`

### To Container

- `docker cp README.md alpine:/`

### From Container

- `docker cp alpine:/lib .`

##  Diff

- `docker diff alpine`

# Networking

- `docker network COMMAND`
- `docker network ls`

## Bridge Driver

### Bridge network (default, legacy, not recommneded in prod)

- `docker run -it -d --name alpine1 alpine sh`
- `docker run -it -d --name alpine2 alpine sh`
- `docker network ls`
- `docker network inspect bridge`
- `docker inspect alpine1`
- `docker attach alpine1`
  - `ip addr show`
    - lo shows the localhost (172.17.0.1)
    - eth0 shows ip address (172.17.0.2) for the container
  - `ping google.com` - avaiable as the container connects to the bridge
  - `ping 127.0.0.3`- can connect to another conainer conneceted to the bridge
  - `ping alpine2` - doesn't work as DNS is not available at the default bridge
  - Delete containers first
    - `docker kill alpine1 alpine2`
    - `docker rm alpine1 alpine2`

### User Defined Network (preferred)

- DNS names are availabe
- Create networks:
  - `docker network create custom-net-1`
  - `docker network create custom-net-2`
  - `docker network ls`
  - Create containers :
  - `docker run -it -d --network custom-net-1 --name alpine11 alpine sh`
  - `docker run -it -d --network custom-net-1 --name alpine12 alpine sh`
  - `docker run -it -d --network custom-net-1 --name alpine13 alpine sh`
  - `docker network connect custom-net-2 alpine13`
  - `docker run -it -d --network custom-net-2 --name alpine14 alpine sh`
  - Check networks:
  - `docker network inspect custom-net-1`
  - `docker network inspect custom-net-2`
  - Check connetctions:
  - From alpine11
  - `docker attach alpine11`
  - `ping alpine13` - OK
  - `ping alpine14` - bad address 'alpine14'
- From alpine13
  - `docker attach alpine13`
  - `ping alpine12` - OK
  - `ping alpine14` - OK
- Delete networks
  - Delete containers first
    - `docker kill alpine11 alpine12 alpine13 alpine14`
    - `docker rm alpine11 alpine12 alpine13 alpine14`
- Delete networks
  - `docker network rm custom-net-1 custom-net-2`
  - `docker network ls`

### Port Forwarding

- Create container:
  - `docker run -it -d -e POSTGRES_PASSWORD=postgres -p 5434:5432 --name postgres postgres` - 5434 is a port on the host machine
  - `docker ps`
- Check port
  - `sudo lsof -i :5434`
  - Connect from outside
    - `ifconfig en0` - take ip address: 192.168.1.45
    - `telnet 192.168.1.45 5434`
- Windows/MacOs
  - Uses a virtual machine
    - `docker run -it --rm --privileged --pid=host justincormack/nsenter1`
    - `ip addr show | grep docker` - take docker address, i.e. 172.17.0.1
  - TBD
    - `docker run -it -d --name alpine21 alpine sh`
    - `docker attach alpine21`
    - `traceroute 192.168.1.45` - host ip

## Host Driver

- Doesn't work on Windows/MacOs as uses a virtual machine
- `docker run -it -d --network host --name alpine31 alpine sh`
- `docker inspect alpine31`
- `docker network inspect host`
- `docker attach alpine31`
  - `traceroute google.com`

## None Driver

- Use cases:
  - Run one-time job in an isoilated environment
  - Run some script which doesn't use Internet
- `docker run -it -d --network none --name alpine41 alpine sh`
- `docker inspect alpine41`
- `docker network inspect none`
- `docker attach alpine41`
  - `ping google.com` - bad address 'google.com'
  - `ping 172.17.0.1` - sendto: Network unreachable
  - `ip addr show` - there is only access to the local host

# Custom images

## Basic

- Build image
  - `docker build -f Dockerfile .`
    - `docker build .`
      - `dive 589`
      - `docker run -it 589 sh`
        - `docker inspect 589`
    - `docker build --build-arg alpine_vesrion=3 --build-arg foo=Foo -f Dockerfile .`
- Entry point
  - ENTRYPOINT - process to run
  - CMD - process params
  - `docker run -it 653 start` - run tomcat with start (default is run)
- Cache
  - `docker build --no-cache .`

## Tag images

### With -t option

- `docker build -t repo_name/my-first-tag:1.0 .`
  - `docker run repo_name/my-first-tag:1.0`

### With tag command (used more frequently)

- `docker tag d595e854deed repo_name/my-tomcat:1.0`
  - `docker tag d595e854deed repo_name/my-tomcat:1.1` - add one more tag to the same image

## Multi stage builds (located in the multi-stage folder)

- `cd multi-stage`
- `docker build .`
- `docer run 83q`

## Build Context

- Docker file is always taken from a context

### From std in

- `docker build -f- . <<EOF`
- `FROM alpine`
- `RUN touch test.txt`
- `EOF`

### Without Context

- `docker build - <<EOF`
- `FROM alpine`
- `EOF`

### By URL

### From archive

## Push images

### Authentication

- `docker login`
  - `cat ~/.docker/config.json` - auth info stored here
- `docker login localhost:8080`
- `docker login -u some_user -p some_pass`
- `cat ~/my_password.txt | docker login -u some_user -password-stdin`

### Pushing

- `docker push repo_name/my-first-tag:1.0`

### Logout

- `docker logout`

# Best practices

- Use multi-stage builds
- Use docker cache
  - Order docker instructions properly
  - Keeps layers and images small (install apps)
  - Minimize number of layers (RUN)
- Reduce build contex
  - Don't include unnecessary file (COPY)
  - Use .dockerignore
- Use an appropriate image (alpine)
- Decouple application (ENTRYPOINT)

# Docker Compose

- `docker-compose version`
- `docker compose version`

## Basic

- `docker compose --help` - available commands
- `docker compose build` - Build or rebuild services
- `docker compose up` - Create and start containers
  - `docker compose up -d` - Create and start containers in the detached mode 
  - `docker ps`
  - `docker network ls` - docker-pg_default appeared (bridge type)
  - Ctrl+C - to stop docker compose
- `docker compose up --build` -
- `docker compose logs` - View output from containers
- `docker compose pause` - Pause services
  - `docker ps` - status is Paused
- `docker compose unpause` - Unpause services
- `docker compose stop` - Stop service
- `docker compose start` - Start services 
- `docker compose restart` - Restart service containers 
- `docker compose cp ./test-file.md first:/` - Copy files/folders between a service container and the local filesystem
- `docker compose exec first ls -all` - Execute a command in a running container
  - `docker compose exec --help`
- `docker compose rm` - Removes stopped service containers 
- `docker compose down` - Stop and remove containers, networks

## Compose file

- by default compose.yaml is used
- `docker compose -f compose.yaml up -d` 
  - `docker compose -f compose.yaml down` 


# Examples

# example-1

Builds a java app.

## Pure Docker

### Create a network

- `docker network create example-1-net`
 
### Create a database

- `docker run -d -e POSTGRES_PASSWORD=pass --name postgres --network example-1-net postgres`

### Build java app

- `docker build -f ./prod.Dockerfile .`
- `docker run -d --name web --network example-1-net -p 8082:8080 687`
- Open localhost:8082

## Docker Compose

- `docker compose up -d` -  example-1-database-1 container is available
  - `docker compose logs`
    - `docker compose logs database`
- Open localhost:8083
