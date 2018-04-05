# DB2 setup

NB: this was not translated to a proper bash script yet.
For now, you have to copy and paste this code to your terminal.

please execute `private.sh` before this script in order to setup variables

```bash
# then connect to d1:
ssh rhel@$jumpbox
ssh 192.168.1.20
sudo su
#format data disk and mount it

printf "n\np\n1\n\n\np\nw\n" | fdisk /dev/sdc
# answer n,p,1,<default>,<default>, p, then w

printf "\n" | mkfs -t ext4 /dev/sdc1
# answer <default>

mkdir /data1
mount /dev/sdc1 /data1
cat >> /etc/fstab << EOF
/dev/sdc1   /data1  auto    defaults,nofail 0   0
EOF

cd /data1
mkdir db2bits/
cd db2bits/
curl -o v11.1_linuxx64_server_t.tar.gz "$db2bits"

#TODO: have to copy the script so that it is available
./start_network.sh

# cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055342.html?pos=3
cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
PasswordAuthentication no
EOF

ssh-keygen -t dsa -f /root/.ssh/id_dsa -q -N ""
cp /root/.ssh/id_dsa.pub /home/rhel/root_id_dsa.pub

#back to the jumbox
exit # exit from sudo su
exit # exit from 192.168.1.20

scp rhel@192.168.1.20:/home/rhel/root_id_dsa.pub .

# TODO - this has to be done on all nodes d1 (for what has not already been done), d2 to d4, cf1 and cf2
# {all_db2_nodes{
nodeip=192.168.1.21

scp root_id_dsa.pub rhel@$nodeip:/home/rhel/
ssh $nodeip
sudo su
cat /home/rhel/root_id_dsa.pub >> /root/.ssh/authorized_keys
cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
EOF
dhclient

# install pre-requisistes
yum update -y
yum install -y gcc gcc-c++ libstdc++*.i686 numactl sg3_utils kernel-devel compat-libstdc++-33.i686 compat-libstdc++-33.x86_64 pam-devel.i686 pam-devel.x86_64 ksh 

sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config

#TODO: have to copy the script so that it is available
./start_network.sh

reboot
# back to jumpbox
sleep 60s
ssh $nodeip
sudo su

yum install -y iscsi-initiator-utils device-mapper-multipath.x86_64

# setup multipath.conf 
cat << EOF >> /etc/multipath.conf 
defaults { 
    user_friendly_names no 
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
    devnode "^sdc[0-9]*" 
    devnode "^cciss.*" 
} 
devices { 
}
EOF

modprobe dm-multipath 
service multipathd start 
chkconfig multipathd on

multipath -l


iscsiadm -m discovery -t sendtargets -p 192.168.1.30
iscsiadm -m session 
multipath -l

fdisk -l | grep /dev/mapper/3

# TODO: extract those 2 variables from 
# Disk /dev/mapper/360003ff44dc75adc882c5583a561aa53: 9999 MB, 9999220736 bytes, 19529728 sectors
# Disk /dev/mapper/360003ff44dc75adcbdecfe2f0b22c7c6: 9999 MB, 9999220736 bytes, 19529728 sectors

exit
exit
# back to the jumpbox
# }all_db2_nodes}

ssh 192.168.1.20
sudo su

# db2_install help : https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0023669.html
/data1/db2bits/server_t/db2_install -y -b /opt/IBM/db2 -p SERVER -f PURESCALE -t /tmp/db2_install.trc -l /tmp/db2_install.log


```


