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

### User Defined Network

- `docker run -it -d --name alpine1 alpine sh`