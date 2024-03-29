#!/bin/bash

DIR=$(pwd)
CFGDIR=$DIR/conf/srl-r1
mkdir -p $CFGDIR

echo "-- CFGDIR=$CFGDIR"

# Start r1 docker
docker run -t -d --rm \
  --name r1 \
  --hostname=r1 \
  --user=0:0 \
  --volume=$DIR/topology.yml:/tmp/topology.yml:ro \
  --volume=$DIR/r1.cfg:/etc/opt/srlinux/r1.cfg \
  --volume=$CFGDIR:/etc/opt/srlinux/:rw \
  --privileged \
  ghcr.io/nokia/srlinux \
  sudo bash -c "/opt/srlinux/bin/sr_linux"

#docker run \
#--name r1 \
#--hostname=r1 \
#--user=0:0 \
#--mac-address=02:fd:00:00:02:00 \
#--env=CLAB_INTFS=3 \
#--env=CLAB_LABEL_CLAB_NODE_TYPE=ixrd2 \
#--env=CLAB_LABEL_CLAB_NODE_GROUP= \
#--env=SRLINUX=1 \
#--env=CLAB_LABEL_CONTAINERLAB=r1 \
#--env=CLAB_LABEL_CLAB_NODE_NAME=r1 \
#--env=CLAB_LABEL_CLAB_NODE_KIND=nokia_srlinux \
#--volume=$CFGDIR:/etc/opt/srlinux/:rw \
#--volume=$DIR/r1.cfg:/etc/opt/srlinux/r1.cfg \
#--volume=$DIR/topology.yml:/tmp/topology.yml:ro \
#--privileged \
#--network=clab \
#--privileged \
#--label='clab-node-type=ixrd3' \
#--label='clab-node-kind=nokia_srlinux' \
#--label='clab-mgmt-net-bridge=br-c4e26cc57c2a' \
#--label='clab-topo-file=/home/david/vnx/vnx-docker/clab-examples/srl01/srl01.clab.yml' \
#--label='containerlab=srl01' \
#--label='clab-node-lab-dir=/home/david/vnx/vnx-docker/clab-examples/clab-srl01/srl' \
#--label='clab-node-group=' \
#--label='clab-node-name=r1' \
#--label='clab-node-kind=nokia_srlinux' \
#--runtime=runc \
#-d  \
#-t \
#ghcr.io/nokia/srlinux:23.7.1 \
#sudo bash -c 'touch /.dockerenv && /opt/srlinux/bin/sr_linux'

sleep 5

# Creamos los veth y los conectamos al docker r1 y a los switches
sudo ovs-docker add-port Net0 e1-1 r1
sudo ovs-docker add-port Net1 e1-2 r1
sudo ovs-docker add-port Net3 e1-3 r1

# Deshabilitamos el tcp offload
docker exec r1 ethtool -K e1-1 tx off
docker exec r1 ethtool -K e1-2 tx off
docker exec r1 ethtool -K e1-3 tx off
#docker exec r1 ethtool -K e1-1 rx off
#docker exec r1 ethtool -K e1-2 rx off
#docker exec r1 ethtool -K e1-3 rx off

# Desactivamos las variables que deshabilita clab con SR linux
docker exec r1 sudo bash -c "echo 0 >  /proc/sys/net/ipv4/ip_forward"
docker exec r1 sudo bash -c "echo 0 >  /proc/sys/net/ipv6/conf/all/accept_dad"
docker exec r1 sudo bash -c "echo 0 >  /proc/sys/net/ipv6/conf/all/autoconf"
docker exec r1 sudo bash -c "echo 0 >  /proc/sys/net/ipv6/conf/all/disable_ipv6"
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/default/accept_dad "
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/default/autoconf "

# Comprobamos que están deshabilitadas
docker exec r1 cat /proc/sys/net/ipv4/ip_forward
docker exec r1 cat /proc/sys/net/ipv6/conf/all/accept_dad
docker exec r1 cat /proc/sys/net/ipv6/conf/all/autoconf
docker exec r1 cat /proc/sys/net/ipv6/conf/all/disable_ipv6
docker exec r1 cat /proc/sys/net/ipv6/conf/default/accept_dad
docker exec r1 cat /proc/sys/net/ipv6/conf/default/autoconf

sleep 10

# Cargamos configuracion en el router r1
docker exec r1 sr_cli source /etc/opt/srlinux/r1.cfg
