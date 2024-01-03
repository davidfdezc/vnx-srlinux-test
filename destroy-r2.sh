#!/bin/bash

sudo ovs-docker del-ports Net1 r2
sudo ovs-docker del-ports Net2 r2
docker stop r2
docker rm r2
