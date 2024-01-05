#!/bin/bash

sudo ovs-vsctl del-port Net0 r1-e1
sudo ovs-vsctl del-port Net1 r1-e2
sudo ovs-vsctl del-port Net3 r1-e3

docker stop r1
docker rm r1
