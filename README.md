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