# DB2 setup

NB: this was not translated to a proper bash script yet.
For now, you have to copy and paste this code to your terminal.

please execute `private.sh` before this script in order to setup variables

```bash
# then connect to d1:
ssh rhel@$jumpbox
ssh 192.168.1.20
sudo su

mkdir /data2
cd /data2
mkdir db2bits/
cd db2bits/
curl -o v11.1_linuxx64_server_t.tar.gz "$db2bits"

#TODO: have to copy the script so that it is available
./start_network.sh

# cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055342.html?pos=3
cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
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

cat << EOF >> /etc/ssh/ssh_config 
Port 22
Protocol 2,1
EOF

firewall-cmd --add-port=56000/tcp --permanent
firewall-cmd --add-port=56001/tcp --permanent
firewall-cmd --add-port=50000/tcp --permanent
firewall-cmd --add-port=60000-60005/tcp --permanent
firewall-cmd --reload

# install pre-requisistes
yum update -y
yum install -y gcc gcc-c++ libstdc++*.i686 numactl sg3_utils kernel-devel compat-libstdc++-33.i686 compat-libstdc++-33.x86_64 pam-devel.i686 pam-devel.x86_64 ksh iscsi-initiator-utils device-mapper-multipath.x86_64

sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config
#reboot needed?

#TODO: have to copy the script so that it is available
./start_network.sh

#format data disk and mount it
printf "n\np\n1\n\n\np\nw\n" | fdisk /dev/sdc
printf "\n" | mkfs -t ext4 /dev/sdc1
mkdir /data1
mount /dev/sdc1 /data1
cat >> /etc/fstab << EOF
/dev/sdc1   /data1  auto    defaults,nofail 0   0
EOF

#if [ `hostname` != "cf1" ] && [ `hostname` != "cf1" ]
#then # {connect to iscsi{
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

cat /etc/iscsi/initiatorname.iscsi
# this has to be put on the iSCSI target servers so that they accept connections from this node

iscsiadm -m discovery -t sendtargets -p 192.168.1.30
iscsiadm -m node -L automatic
iscsiadm -m session 
multipath -l

fdisk -l | grep /dev/mapper/3

#fi # }connect to iscsi}

cat << EOF >> /etc/hosts 
192.168.3.20 d1
192.168.1.20 d1b
192.168.3.21 d2
192.168.1.21 d2b
192.168.3.40 cf1
192.168.1.40 cf1b
192.168.3.41 cf2
192.168.1.41 cf2b
EOF

reboot
# back to jumpbox
# }all_db2_nodes}

ssh 192.168.1.20
sudo su

cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys
scp /root/.ssh/id_dsa 192.168.1.21:/root/.ssh
scp /root/.ssh/id_dsa 192.168.1.40:/root/.ssh
scp /root/.ssh/id_dsa 192.168.1.41:/root/.ssh


# db2_install help : https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0023669.html
#/data1/db2bits/server_t/db2_install -y -b /opt/IBM/db2 -p SERVER -f PURESCALE -t /tmp/db2_install.trc -l /tmp/db2_install.log
# this leads to a GPFS exception. So try the Db2 setup wizard which requires GUI

# install GUI
yum group install "Server with GUI"
#check if the following lines are needed
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
firewall-cmd --add-port=3389/tcp --permanent
firewall-cmd --reload

passwd root
```

Setup an ssh tunnel. Example: `ssh -L 8034:192.168.1.20:3389 rhel@$jumpbox`

Connect from an RDP client (e.g.: Windows + R, `mstsc`) and connect to `localhost:8034`

Note that at this stage, devices look like this: 

```
[root@d1 rhel]# lsblk
NAME                                    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
fd0                                       2:0    1    4K  0 disk
sda                                       8:0    0   32G  0 disk
├─sda1                                    8:1    0  500M  0 part  /boot
└─sda2                                    8:2    0 31.5G  0 part  /
sdb                                       8:16   0   28G  0 disk
└─3600224808df59698273b75f41aea9df8     253:0    0   28G  0 mpath
  └─3600224808df59698273b75f41aea9df8p1 253:1    0   28G  0 part
sdc                                       8:32   0   10G  0 disk
└─sdc1                                    8:33   0   10G  0 part  /data1
sdd                                       8:48   0  9.3G  0 disk
└─360003ff44dc75adc882c5583a561aa53     253:2    0  9.3G  0 mpath
sde                                       8:64   0  9.3G  0 disk
└─360003ff44dc75adcbdecfe2f0b22c7c6     253:4    0  9.3G  0 mpath
sdf                                       8:80   0 93.1G  0 disk
└─360003ff44dc75adc8cdd40a1f6c43aa5     253:3    0 93.1G  0 mpath
sdg                                       8:96   0 93.1G  0 disk
└─360003ff44dc75adca79cdb4c4e6408ec     253:5    0 93.1G  0 mpath
```


from the GUI, open a terminal and run 

```bash
/data1/db2bits/server_t/db2setup -l /tmp/db2setup.log -t /tmp/db2setup.trc
```

Documentation is [here](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0054851.html?pos=2)

Here is how the setup is filled: 

Screen name | Field | Value | Comments
------------|-------|-------|---------
Welcome | | New Install |
Choose a Product | | DB2 Version 11.1.2.2. Server Editions with DB2 pureScale |
Configuration | Directory | /data1/opt/ibm/db2/V11.1 |
'' | Select the installation type | Typical |
''| I agree to the IBM terms | checked |
Instance Owner | Password and Confirm password | ##obfuscated## |
Fenced User | Password and Confirm password | ##obfuscated## |
Cluster File System | Shared disk partition device path | /dev/sdd |
'' | Mount point | /db2sd_1804a |
'' | Shared disk for data | /dev/sdf |
'' | Mount point (Data) | /db2fs/datafs1 |
'' | Shared disk for log | /dev/sdg |
'' | Mount point (Log) | /db2fs/logfs1 |
'' | DB2 Cluster Services Tiebreaker. Device path | /dev/sde |
Host List | d1 [eth1], d2 [eth1], cf1 [eth1], cf3 [eth1]|
'' | Preferred primary CF | cf1 |
'' | Preferred primary CF | cf2 |
Response File and Summary | first option | Install DB2 Server Edition with the IBM DB2 pureScale feature and save my settings in a response file
'' | Response file name | /root/db2server.rsp

