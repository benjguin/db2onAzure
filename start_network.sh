#!/bin/bash

#adapted from https://docs.microsoft.com/en-us/azure/virtual-machines/linux/multiple-nics

ip=`hostname -I`
lastip=`echo ${ip//*.}`

echo "200 eth0-rt" >> /etc/iproute2/rt_tables
echo "201 eth1-rt" >> /etc/iproute2/rt_tables

cat >  /etc/sysconfig/network-scripts/ifcfg-eth1 << EOF
BOOTPROTO=dhcp  
DEVICE=eth1
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
NM_CONTROLLED=no  
EOF

cat > /etc/sysconfig/network-scripts/rule-eth0 << EOF
from 192.168.1.$lastip/32 table eth0-rt
to 192.168.1.$lastip/32 table eth0-rt
EOF

cat > /etc/sysconfig/network-scripts/route-eth0 << EOF
192.168.1.0/24 dev eth0 table eth0-rt
default via 0.0.0.0 dev eth0 table eth0-rt
EOF

cat > /etc/sysconfig/network-scripts/rule-eth1 << EOF
from 192.168.3.$lastip/32 table eth1-rt
to 192.168.3.$lastip/32 table eth1-rt
EOF

cat > /etc/sysconfig/network-scripts/route-eth1 << EOF
192.168.3.0/24 dev eth1 table eth1-rt
default via 0.0.0.0 dev eth1 table eth1-rt
EOF

systemctl restart network

dhclient
