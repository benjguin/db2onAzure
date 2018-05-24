#!/bin/bash

#install and configure gluster

#setup DNS static
cat >> /etc/hosts <<EOF
192.168.1.10 g0
192.168.1.11 g1
192.168.1.12 g2

192.168.2.10 g0b
192.168.2.11 g1b
192.168.2.12 g2b
EOF

#Install stuff
yum update -y
cat > /etc/yum.repos.d/Gluster.repo <<'EOF'
[gluster312]
name=Gluster 3.12
baseurl=http://mirror.centos.org/centos/7/storage/$basearch/gluster-3.12/
gpgcheck=0
enabled=1
EOF

yum install glusterfs glusterfs-cli glusterfs-libs glusterfs-server -y

#prepare the disks
pvcreate /dev/sdc
pvcreate /dev/sdd
vgcreate vg_gluster /dev/sdc /dev/sdd

lvcreate -L 1999G -n brick1 vg_gluster

mkfs.xfs /dev/vg_gluster/brick1

mkdir -p /bricks/db2data

mount /dev/vg_gluster/brick1 /bricks/db2data/

mkdir -p /bricks/db2data/db2data

cat >> /etc/fstab <<EOF
/dev/vg_gluster/brick1  /bricks/db2data    xfs     defaults    0 0
EOF

#firewall
#TODO: allow on interface eth1 instead of eth0
firewall-cmd --zone=public --add-port=24007-24010/tcp --permanent
firewall-cmd --zone=public --add-port=49152-49160/tcp --permanent
firewall-cmd --zone=public --add-port=3260/tcp --permanent
firewall-cmd --reload

#start gluster
systemctl enable glusterd
systemctl start glusterd

#gluster block

yum -y install http://cbs.centos.org/kojifiles/packages/tcmu-runner/1.3.0/0.2rc4.el7/x86_64/libtcmu-1.3.0-0.2rc4.el7.x86_64.rpm
yum -y install http://cbs.centos.org/kojifiles/packages/tcmu-runner/1.3.0/0.2rc4.el7/x86_64/tcmu-runner-1.3.0-0.2rc4.el7.x86_64.rpm
yum -y install http://cbs.centos.org/kojifiles/packages/tcmu-runner/1.3.0/0.2rc4.el7/x86_64/tcmu-runner-handler-glfs-1.3.0-0.2rc4.el7.x86_64.rpm
yum -y install http://cbs.centos.org/kojifiles/packages/gluster-block/0.3/2.el7/x86_64/gluster-block-0.3-2.el7.x86_64.rpm

systemctl start gluster-blockd
systemctl enable gluster-blockd
systemctl status gluster-blockd