sudo containerlab deploy --topo srlinux_topology.yaml

# Disable TCP offload in veth interfaces
docker exec clab-nokiasr1-r1 ethtool -K e1-1 tx off
docker exec clab-nokiasr1-r1 ethtool -K e1-2 tx off
docker exec clab-nokiasr1-r1 ethtool -K e1-3 tx off
docker exec clab-nokiasr1-r1 ethtool -K e1-1 rx off
docker exec clab-nokiasr1-r1 ethtool -K e1-2 rx off
docker exec clab-nokiasr1-r1 ethtool -K e1-3 rx off

# Disable TCP offload in veth interfaces
docker exec clab-nokiasr1-r2 ethtool -K e1-1 tx off
docker exec clab-nokiasr1-r2 ethtool -K e1-2 tx off
