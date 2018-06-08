#!/bin/bash

db2bits=$1
nbDb2MemberVms=$2
nbDb2CfVms=$3
acceleratedNetworkingOnDB2=$4
lisbits=$5

echo "---------------------------------------------------"
echo "db2bits=[$db2bits]"
echo "nbDb2MemberVms=[$nbDb2MemberVms]"
echo "nbDb2CfVms=[$nbDb2CfVms]"
echo "acceleratedNetworkingOnDB2=[$acceleratedNetworkingOnDB2]"
echo "lisbits=[$lisbits]"
echo "---------------------------------------------------"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055342.html?pos=3
cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
EOF

mkdir /data2
cd /data2
mkdir db2bits/
cd db2bits/
curl -o v11.1_linuxx64_server_t.tar.gz "$db2bits"
tar xzvf v11.1_linuxx64_server_t.tar.gz

source /home/rhel/start_network.sh

systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
# TODO: update firewall instead of disabling it - For now, the following is not sufficient:
# cf <https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/r0061630.html?pos=2>
#firewall-cmd --add-port=56000/tcp --permanent
#firewall-cmd --add-port=56001/tcp --permanent
#firewall-cmd --add-port=50000/tcp --permanent
#firewall-cmd --add-port=60000-60005/tcp --permanent
#firewall-cmd --add-port=1191/tcp --permanent
#firewall-cmd --add-port=12347/udp --permanent
#firewall-cmd --add-port=12348/udp --permanent
#firewall-cmd --add-port=657/udp --permanent
#firewall-cmd --reload

# install pre-requisistes
yum install -y \
    binutils \
    binutils-devel \
    compat-libstdc++-33.i686 \
    compat-libstdc++-33.x86_64 \
    cpp \
    dapl \
    device-mapper-multipath.x86_64 \
    file \
    gcc \
    gcc-c++ \
    glibc \
    ibacm \
    ibutils \
    iscsi-initiator-utils \
    kernel-devel-3.10.0-514.el7.x86_64 \
    kernel-headers-3.10.0-514.el7.x86_64 \
    ksh \
    libcxgb3 \
    libgcc \
    libgomp \
    libibcm \
    libibmad \
    libibverbs \
    libipathverbs \
    libmlx4 \
    libmlx5 \
    libmthca \
    libnes \
    librdmacm \
    libstdc++ \
    libstdc++*.i686 \
    m4 \
    make \
    ntp \
    ntpdate \
    numactl \
    openssh \
    pam-devel.i686 \
    pam-devel.x86_64 \
    patch \
    perl-Sys-Syslog \
    rdma \
    rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto \
    sg3_utils \
    sg3_utils-libs

cat /etc/iscsi/initiatorname.iscsi

cat << EOF >> /etc/hosts 
192.168.0.60
192.168.1.60 witn0-eth1
192.168.3.60 witn1-eth2
192.168.4.60 witn1-eth3
EOF


for (( i=0; i<$nbDb2MemberVms; i++ ))
do
    cat << EOF >> /etc/hosts 
192.168.0.2${i} d${i}
192.168.1.2${i} d${i}-eth1
192.168.3.2${i} d${i}-eth2
192.168.4.2${i} d${i}-eth3
EOF
done

for (( i=0; i<$nbDb2CfVms; i++ ))
do
    cat << EOF >> /etc/hosts 
192.168.0.3${i} cf${i}
192.168.1.3${i} cf${i}-eth1
192.168.3.3${i} cf${i}-eth2
192.168.4.3${i} cf${i}-eth3
EOF
done

mkdir /data1

#https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055374.html?pos=2
groupadd --gid 341 db2iadm1
groupadd --gid 342 db2fadm1
useradd -g db2iadm1 -m -d /home/db2sdin1 db2sdin1
useradd -g db2fadm1 -m -d /home/db2sdfe1 db2sdfe1

rm -rf /home/db2sdin1/.ssh/
rsync -av /home/rhel/.ssh/ /home/db2sdin1/.ssh
chown -R db2sdin1:db2iadm1 /home/db2sdin1/.ssh

mkdir -p /var/ct/cfg/
# define the witness. cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0061581.html
cat <<EOF > /var/ct/cfg/netmon.cf
!IBQPORTONLY !ALL
!REQD eth0 192.168.0.60
!REQD eth1 192.168.1.60
!REQD eth2 192.168.3.60
EOF

uname -r
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
# please do **not** point to Red Hat Enterprise Linux Server (3.10.0-514.28.1.el7.x86_64) 7.3 (Maipo)
grub2-set-default 'Red Hat Enterprise Linux Server (3.10.0-514.el7.x86_64) 7.3 (Maipo)'
cat /boot/grub2/grubenv |grep saved
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg
# NB: a reboot is required and will be done after ARM deploys

sestatus
sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config
setenforce 0
sestatus

uname -r
df

if [ "$acceleratedNetworkingOnDB2" == "true" ]
then
    mkdir /tmp/lis
    cd /tmp/lis
    curl -o lis-rpms-4.2.4-2.tar.gz "$lisbits"
    tar xvf lis-rpms-4.2.4-2.tar.gz
fi