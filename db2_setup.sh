#!/bin/bash

# please execute private.sh before this script in order to setup variables

ssh rhel@$jumpbox
sudo su
#format data disk and mount it

printf "n\np\n1\n\n\np\nw\n" | fdisk /dev/sdc
# answer n,p,1,<default>,<default>, p, then w

printf "\n" | mkfs -t ext4 /dev/sdc1
# answer <default>

mkdir /data1
mount /dev/sdc1 /data1

cd /data1
mkdir db2bits/
cd db2bits/
curl -o v11.1_linuxx64_server_t.tar.gz "$db2bits"

# make the d1-cluster NIC work
# <https://docs.microsoft.com/en-us/azure/virtual-machines/linux/multiple-nics#configure-guest-os-for-multiple-nics>
echo "200 eth0-rt" >> /etc/iproute2/rt_tables
echo "201 eth1-rt" >> /etc/iproute2/rt_tables

cat > /etc/sysconfig/network-scripts/rule-eth0 << EOF
from 192.168.1.20/32 table eth0-rt
to 192.168.1.20/32 table eth0-rt
EOF

cat > /etc/sysconfig/network-scripts/route-eth0 << EOF
192.168.1.0/24 dev eth0 table eth0-rt
default via 0.0.0.0 dev eth0 table eth0-rt
EOF

cat > /etc/sysconfig/network-scripts/rule-eth1 << EOF
from 192.168.3.20/32 table eth1-rt
to 192.168.3.20/32 table eth1-rt
EOF

cat > /etc/sysconfig/network-scripts/route-eth1 << EOF
192.168.3.0/24 dev eth1 table eth1-rt
default via 0.0.0.0 dev eth1 table eth1-rt
EOF

systemctl restart network

dhclient

cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
PasswordAuthentication no
EOF