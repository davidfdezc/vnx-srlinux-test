#!/bin/bash

DIR=$(pwd)
CFGDIR=$DIR/conf/srl-r1
mkdir -p $CFGDIR

echo "-- CFGDIR=$CFGDIR"

# Start r1 docker
docker run -d --name r1 --privileged ubuntu sleep 3600

sleep 8
sudo ovs-docker add-port Net0 e1-1 r1
sudo ovs-docker add-port Net1 e1-2 r1
sudo ovs-docker add-port Net3 e1-3 r1

# Disable TCP offload in veth interfaces
#docker exec r1 ethtool -K e1-1 tx off
#docker exec r1 ethtool -K e1-2 tx off
#docker exec r1 ethtool -K e1-3 tx off
#docker exec r1 ethtool -K e1-1 rx off
#docker exec r1 ethtool -K e1-2 rx off
#docker exec r1 ethtool -K e1-3 rx off

#docker exec r1 sr_cli source /etc/opt/srlinux/r1.cfg

docker exec -ti r1 bash -c "
apt update && apt install -y iproute2 iputils-ping
ip addr add 10.1.0.1/24 dev e1-1
ip addr add 10.1.1.1/24 dev e1-2
ip addr add 10.1.3.1/24 dev e1-3
ip route add 10.1.2.0/24 via 10.1.1.2
"
