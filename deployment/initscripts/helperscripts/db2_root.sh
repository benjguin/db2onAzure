#!/bin/bash

db2bits=$1
nbDb2MemberVms=$2
nbDb2CfVms=$3

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
192.168.0.3${i} d${i}
192.168.1.3${i} d${i}-eth1
192.168.3.3${i} d${i}-eth2
192.168.4.3${i} d${i}-eth3
EOF
done

#format data disk and mount it
#TODO: data disk may be on sdb or sdc
#dataon=sdb
dataon=sdc
printf "n\np\n1\n\n\np\nw\n" | fdisk /dev/$dataon
printf "\n" | mkfs -t ext4 /dev/${dataon}1
mkdir /data1
mount /dev/${dataon}1 /data1
if [ "$dataon" == "sdc" ]
then 
cat >> /etc/fstab << EOF
/dev/sdc1   /data1  auto    defaults,nofail 0   0
EOF
else
cat >> /etc/fstab << EOF
/dev/sdb1   /data1  auto    defaults,nofail 0   0
EOF
fi

# setup multipath.conf 
cat << EOF > /etc/multipath.conf 
defaults { 
    user_friendly_names no
    bindings_file /etc/multipath/bindings4db2
    max_fds max
    flush_on_last_del yes 
    queue_without_daemon no 
    dev_loss_tmo infinity
    fast_io_fail_tmo 5
} 
blacklist { 
    wwid "SAdaptec*" 
    devnode "^hd[a-z]" 
    devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*" 
    devnode "^sda[0-9]*" 
    devnode "^sdb[0-9]*" 
    devnode "^sdc[0-9]*" 
    devnode "^cciss.*" 
} 
multipaths {
    multipath {
        wwid  36001405149ee39c319845aaa710099a7
        alias db2data1  
    }
    multipath {
        wwid  36001405bfc71ff861174f2bbb0bfea37
        alias db2log1  
    }
    multipath {
        wwid  36001405484ba6ab80934f2290a2b579f
        alias db2shared
    }
    multipath {
        wwid  36001405645b2e72c56142ef97932cb95
        alias db2tieb 
    }
}
EOF
# the 4 values 
# 36001405149ee39c319845aaa710099a7, 36001405bfc71ff861174f2bbb0bfea37, 36001405484ba6ab80934f2290a2b579f and 36001405645b2e72c56142ef97932cb95
# will be replaced by a script to take the actual values from the GlusterFS cluster

modprobe dm-multipath 
service multipathd start 
chkconfig multipathd on
multipath -l
#iscsiadm -m discovery -t sendtargets -p 192.168.1.10
iscsiadm -m discovery -t sendtargets -p 192.168.1.30
iscsiadm -m node -L automatic 
# TODO: a timeout happens on an IP V6 address for w1 iSCSI target, no consequence
iscsiadm -m session 
multipath -l
fdisk -l | grep /dev/mapper/3
lsblk #inconsistent paths frmo one machine to another
sleep 0.5s
ll /dev/mapper

#fi # }connect to iscsi}

#https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055374.html?pos=2
groupadd --gid 341 db2iadm1
groupadd --gid 342 db2fadm1
useradd -g db2iadm1 -m -d /home/db2sdin1 db2sdin1
useradd -g db2fadm1 -m -d /home/db2sdfe1 db2sdfe1

mkdir -p /var/ct/cfg/
# define the witness. cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0061581.html
cat <<EOF > /var/ct/cfg/netmon.cf
!IBQPORTONLY !ALL
!REQD eth0 192.168.1.60
!REQD eth1 192.168.3.60
EOF

uname -r
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
# please do **not** point to Red Hat Enterprise Linux Server (3.10.0-514.28.1.el7.x86_64) 7.3 (Maipo)
grub2-set-default 'Red Hat Enterprise Linux Server (3.10.0-514.el7.x86_64) 7.3 (Maipo)'
cat /boot/grub2/grubenv |grep saved
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg
# NB: a reboot will be required - this will be done after the ARM templates deployment

sestatus
sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config
setenforce 0
sestatus