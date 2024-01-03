#!/bin/bash

sudo ovs-docker del-ports Net0 r1
sudo ovs-docker del-ports Net1 r1
sudo ovs-docker del-ports Net3 r1
docker stop r1
docker rm r1
