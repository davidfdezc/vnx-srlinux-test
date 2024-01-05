#!/bin/bash

DIR=$(pwd)
CFGDIR=$DIR/conf/srl-r2
mkdir -p $CFGDIR

echo "-- CFGDIR=$CFGDIR"

# Start r2 docker
docker run -t -d --rm \
  --name r2 \
  --hostname=r2 \
  --user=0:0 \
  --volume=$DIR/topology.yml:/tmp/topology.yml:ro \
  --volume=$DIR/r2.cfg:/etc/opt/srlinux/r2.cfg \
  --volume=$CFGDIR:/etc/opt/srlinux/:rw \
  --privileged \
  ghcr.io/nokia/srlinux \
  sudo bash -c "/opt/srlinux/bin/sr_linux"

sleep 5

# Creamos los veth y los conectamos al docker r2 y a los switches
sudo ovs-docker add-port Net1 e1-1 r2
sudo ovs-docker add-port Net2 e1-2 r2

# Deshabilitamos el tx tcp offload
docker exec r2 ethtool -K e1-1 tx off
docker exec r2 ethtool -K e1-2 tx off

# Desactivamos las variables que deshabilita clab con SR linux
docker exec r2 sudo bash -c "echo 0 >  /proc/sys/net/ipv4/ip_forward"
docker exec r2 sudo bash -c "echo 0 >  /proc/sys/net/ipv6/conf/all/accept_dad"
docker exec r2 sudo bash -c "echo 0 >  /proc/sys/net/ipv6/conf/all/autoconf"
docker exec r2 sudo bash -c "echo 0 >  /proc/sys/net/ipv6/conf/all/disable_ipv6"
docker exec r2 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/default/accept_dad "
docker exec r2 sudo bash -c "echo 0 > /proc/sys/net/ipv6/conf/default/autoconf "

# Comprobamos que están deshabilitadas
docker exec r2 cat /proc/sys/net/ipv4/ip_forward
docker exec r2 cat /proc/sys/net/ipv6/conf/all/accept_dad
docker exec r2 cat /proc/sys/net/ipv6/conf/all/autoconf
docker exec r2 cat /proc/sys/net/ipv6/conf/all/disable_ipv6
docker exec r2 cat /proc/sys/net/ipv6/conf/default/accept_dad
docker exec r2 cat /proc/sys/net/ipv6/conf/default/autoconf

sleep 10

# Cargamos configuracion en el router r2
docker exec r2 sr_cli source /etc/opt/srlinux/r2.cfg
