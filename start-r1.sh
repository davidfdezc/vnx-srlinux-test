#!/bin/bash

DIR=$(pwd)
CFGDIR=$DIR/conf/srl-r1
mkdir -p $CFGDIR

echo "-- CFGDIR=$CFGDIR"

# Start r1 docker
docker run \
--name r1 \
--hostname=r1 \
--user=0:0 \
--mac-address=02:fd:00:00:02:00 \
--env=CLAB_INTFS=0 \
--env=CLAB_LABEL_CLAB_NODE_TYPE=ixrd3 \
--env=CLAB_LABEL_CLAB_NODE_GROUP= \
--env=SRLINUX=1 \
--env=CLAB_LABEL_CONTAINERLAB=r1 \
--env=CLAB_LABEL_CLAB_NODE_NAME=r1 \
--env=CLAB_LABEL_CLAB_NODE_KIND=nokia_srlinux \
--volume=$DIR/$CFGDIR:/etc/opt/srlinux/:rw \
--volume=$DIR/r1.cfg:/etc/opt/srlinux/r1.cfg \
--privileged \
-d  \
-it \
ghcr.io/nokia/srlinux \
sudo bash -c 'touch /.dockerenv && /opt/srlinux/bin/sr_linux'
#sudo bash -c 'sleep 30; touch /.dockerenv && /opt/srlinux/bin/sr_linux'

sleep 8
sudo ovs-docker add-port Net0 e1-1 r1
sudo ovs-docker add-port Net1 e1-2 r1
sudo ovs-docker add-port Net3 e1-3 r1

# Disable TCP offload in veth interfaces
docker exec r1 ethtool -K e1-1 tx off
docker exec r1 ethtool -K e1-2 tx off
docker exec r1 ethtool -K e1-3 tx off
docker exec r1 ethtool -K e1-1 rx off
docker exec r1 ethtool -K e1-2 rx off
docker exec r1 ethtool -K e1-3 rx off

docker exec r1 sr_cli source /etc/opt/srlinux/r1.cfg

