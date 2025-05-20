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
