#!/bin/bash

# ip link add bond0 type bond mode 802.3ad lacp_rate fast
# ip link set address 00:00:00:00:00:21 dev bond0
# ip link set eth1 down
# ip link set eth2 down
# ip link set eth1 master bond0
# ip link set eth2 master bond0
# ip link set eth1 up
# ip link set eth2 up 
# ip link set bond0 up
# ip link add link bond0 name bond0.1 type vlan id 1
# ip link set bond0.1 up
# ip addr add 192.168.11.5/24 dev bond0.1
# route del default gw 172.20.20.1 eth0
# route add default gw 192.168.11.1 bond0.1