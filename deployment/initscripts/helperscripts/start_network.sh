#!/bin/bash

#adapted from https://docs.microsoft.com/en-us/azure/virtual-machines/linux/multiple-nics

dhclient
nbnics=`ls -als /sys/class/net/  | grep eth | wc -l`

for (( ni=0; ni<$nbnics; ni++ ))
do
    eth_ip=`ifconfig eth${ni} | awk '$1 == "inet" {print $2}'`
    IFS="." read -ra eth_ipparts <<< "$ethxip"
    eth_subnetip=`echo ${eth_ipparts[2]}`
    lastip=`echo ${eth_ipparts[3]}`

    echo "20${ni} eth${ni}-rt" >> /etc/iproute2/rt_tables

    if [ $ni -gt 0 ]
    then
        cat > /etc/sysconfig/network-scripts/ifcfg-eth${ni} << EOF
BOOTPROTO=dhcp  
DEFROUTE=no
DEVICE=eth${ni}
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
NM_CONTROLLED=no  
EOF
    fi

    cat > /etc/sysconfig/network-scripts/rule-eth${ni}1 << EOF
from 192.168.$eth_subnetip.$lastip/32 table eth${ni}-rt
to 192.168.$eth_subnetip.$lastip/32 table eth${ni}-rt
EOF

    cat > /etc/sysconfig/network-scripts/route-eth${ni} << EOF
192.168.$eth_subnetip.0/24 dev eth${ni} table eth${ni}-rt
default via 0.0.0.0 dev eth${ni} table eth${ni}-rt
EOF

done

systemctl restart network
