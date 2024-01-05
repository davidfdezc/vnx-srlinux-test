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
#sudo bash -c 'sleep 30; touch /.dockerenv && /opt/srlinux/bin/sr_linux'

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

#ghcr.io/nokia/srlinux \
#sudo bash -c 'sleep 30; touch /.dockerenv && /opt/srlinux/bin/sr_linux'

sleep 5

# Desactivamos las variables que deshabilita clab con SR linux
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv4/ip_forward"
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/all/accept_dad"
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/all/autoconf"
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6"
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/default/accept_dad "
docker exec r1 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/default/autoconf "

# Comprobamos que están deshabilitadas
docker exec r1 cat /proc/sys/net/ipv4/ip_forward
docker exec r1 cat /proc/sys/net/ipv6/conf/all/accept_dad
docker exec r1 cat /proc/sys/net/ipv6/conf/all/autoconf
docker exec r1 cat /proc/sys/net/ipv6/conf/all/disable_ipv6
docker exec r1 cat /proc/sys/net/ipv6/conf/default/accept_dad
docker exec r1 cat /proc/sys/net/ipv6/conf/default/autoconf

# Creamos los interfaces veth
sudo ip link add dev r1-e1 type veth peer name e1-1
sudo ip link add dev r1-e2 type veth peer name e1-2
sudo ip link add dev r1-e3 type veth peer name e1-3
sudo ip link set dev r1-e1 up
sudo ip link set dev r1-e2 up
sudo ip link set dev r1-e3 up

# Conectamos el extremo del host a los switches
sudo ovs-vsctl add-port Net0 r1-e1
sudo ovs-vsctl add-port Net1 r1-e2
sudo ovs-vsctl add-port Net3 r1-e3

# Hacemos visible el network namespace de r1
pid=$(docker inspect -f '{{.State.Pid}}' r1)
echo $pid
sudo ln -sfT /proc/$pid/ns/net /var/run/netns/r1
#sudo ip netns exec r1 ifconfig -a

# Movemos los interfaces e1-* al namespace de r1
sudo ip link set e1-1 netns r1
sudo ip link set e1-2 netns r1
sudo ip link set e1-3 netns r1

# Deshabilitamos el tcp offload
echo "-- Deshabilitamos el tcp offload en los interfaces de r1..."
sudo ip netns exec r1 ethtool -K e1-1 tx off
sudo ip netns exec r1 ethtool -K e1-2 tx off
sudo ip netns exec r1 ethtool -K e1-3 tx off

# Levantamos interfaces
sudo ip netns exec r1 ip link set dev e1-1 up
sudo ip netns exec r1 ip link set dev e1-2 up
sudo ip netns exec r1 ip link set dev e1-3 up

sleep 10

# Cargamos configuracion en el router r1
docker exec r1 sr_cli source /etc/opt/srlinux/r1.cfg
