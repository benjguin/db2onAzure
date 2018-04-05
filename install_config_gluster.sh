#!/bin/bash

#install and configure gluster

#setup DNS static
cat >> /etc/hosts <<EOF
192.168.1.10 g1
192.168.1.11 g1
192.168.1.12 g3

192.168.2.10 g1b
192.168.2.11 g1b
192.168.2.12 g3b
EOF

#Install stuff
yum update -y
cat >> /etc/yum.repos.d/Gluster.repo <<EOF
[gluster38]
name=Gluster 3.8
baseurl=http://mirror.centos.org/centos/7/storage/$basearch/gluster-3.8/
gpgcheck=0
enabled=1
EOF

yum install glusterfs glusterfs-cli glusterfs-libs  -y
yum install -y  glusterfs-cli glusterfs-libs glusterfs-server

#prepare the disks
pvcreate /dev/sdc
pvcreate /dev/sdd
vgcreate vg_gluster /dev/sdc /dev/sdd

lvcreate -L 90G -n brick1 vg_gluster
lvcreate -L 9G -n brick2 vg_gluster

mkfs.xfs /dev/vg_gluster/brick1
mkfs.xfs /dev/vg_gluster/brick2

mkdir -p /bricks/db2data
mkdir -p /bricks/db2quorum

mount /dev/vg_gluster/brick1 /bricks/db2data/
mount /dev/vg_gluster/brick2 /bricks/db2quorum/

cat >> /etc/fstab <<EOF
/dev/vg_gluster/brick1  /bricks/db2data    xfs     defaults    0 0
/dev/vg_gluster/brick2  /bricks/db2quorum    xfs     defaults    0 0
EOF

#firewall
firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
firewall-cmd --zone=public --add-port=49152-49160/tcp --permanent
firewall-cmd --reload

#start gluster
systemctl enable glusterd
systemctl start glusterd