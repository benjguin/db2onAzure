#!/bin/bash

#install and configure gluster

yum update -y

cat >> /etc/hosts <<EOF
192.168.1.10 g1
192.168.1.11 g1
192.168.1.12 g3

192.168.2.10 g1b
192.168.2.11 g1b
192.168.2.12 g3b
EOF

yum install glusterfs glusterfs-cli glusterfs-libs glusterfs -y

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