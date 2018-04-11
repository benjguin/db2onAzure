# DB2 setup

## configure the nodes, and setup DB2 pureScale

NB: this was not translated to a proper bash script yet.
For now, you have to copy and paste this code to your terminal.

please execute `private.sh` before this script in order to setup variables

```bash
# then connect to d1:
scp $localgithubfolder/start_network.sh rhel@$jumpbox:~/
ssh rhel@$jumpbox
ssh 192.168.1.20
sudo su

mkdir /data2
cd /data2
mkdir db2bits/
cd db2bits/
curl -o v11.1_linuxx64_server_t.tar.gz "$db2bits"
tar xzvf v11.1_linuxx64_server_t.tar.gz

ssh-keygen -t dsa -f /root/.ssh/id_dsa -q -N ""
cp /root/.ssh/id_dsa.pub /home/rhel/root_id_dsa.pub

#back to the jumbox
exit # exit from sudo su
exit # exit from 192.168.1.20

scp rhel@192.168.1.20:/home/rhel/root_id_dsa.pub .

# TODO - this has to be done on all nodes d1 (for what has not already been done), d2 to d4, cf1 and cf2
# {all_db2_nodes{
nodeip=192.168.1.21

scp -o StrictHostKeyChecking=no root_id_dsa.pub rhel@$nodeip:~/
scp start_network.sh rhel@$nodeip:~/
ssh $nodeip
sudo su
cat /home/rhel/root_id_dsa.pub >> /root/.ssh/authorized_keys
# cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055342.html?pos=3
cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
EOF

#TODO: have to copy the script so that it is available
source /home/rhel/start_network.sh

#cat << EOF >> /etc/ssh/ssh_config 
#Port 22
#Protocol 2,1
#EOF

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
yum update -y
yum install -y gcc gcc-c++ libstdc++*.i686 numactl sg3_utils kernel-devel compat-libstdc++-33.i686 compat-libstdc++-33.x86_64 pam-devel.i686 pam-devel.x86_64 ksh iscsi-initiator-utils device-mapper-multipath.x86_64 m4 perl-Sys-Syslog patch
#TODO: consolidate with previous line
yum install -y libibcm libibverbs librdmacm rdma dapl ibacm ibutils libcxgb3 libibmad libipathverbs libmlx4 libmlx5 libmthca libnes libstdc++ glibc gcc-c++ gcc kernel kernel-devel kernel-headers kernel-firmware ntp ntpdate sg3_utils sg3_utils-libs binutils binutils-devel m4 openssh cpp ksh libgcc file libgomp make patch perl-Sys-Sylog


sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/selinux/config
setenforce 0

# force initiator for the dev environment. Should retrieve them and update the target server instead.
case `hostname` in
"d1")
cat <<EOF >/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.1994-05.com.redhat:c4e37143a6fa
EOF
;;
"d2")
cat <<EOF >/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.1994-05.com.redhat:242e56883d62
EOF
;;
"cf1")
cat <<EOF >/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.1994-05.com.redhat:fd582735ef35
EOF
;;
"cf2")
cat <<EOF >/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.1994-05.com.redhat:b58d9add7fcc
EOF
;;
esac
cat /etc/iscsi/initiatorname.iscsi

cat << EOF >> /etc/hosts 
192.168.3.20 d1
192.168.3.21 d2
192.168.3.40 cf1
192.168.3.41 cf2
192.168.1.20 d1-eth0
192.168.1.21 d2-eth0
192.168.1.40 cf1-eth0
192.168.1.41 cf2-eth0
192.168.3.20 d1-eth1
192.168.3.21 d2-eth1
192.168.3.40 cf1-eth1
192.168.3.41 cf2-eth1
192.168.4.40 cf1-eth2
192.168.4.41 cf2-eth2
192.168.1.30 witn0-eth0
192.168.3.60 witn1-eth1
192.168.4.60 witn1-eth2
EOF

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

iscsiadm -m discovery -t sendtargets -p 192.168.1.30
iscsiadm -m node -L automatic # TODO: a timeout happens on an IP V6 address, no consequence
iscsiadm -m session 
multipath -l

fdisk -l | grep /dev/mapper/3
lsblk

#fi # }connect to iscsi}

#https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0055374.html?pos=2
groupadd --gid 341 db2iadm1
groupadd --gid 342 db2fadm1
useradd -g db2iadm1 -m -d /home/db2sdin1 db2sdin1
useradd -g db2fadm1 -m -d /home/db2sdfe1 db2sdfe1

exit
exit
# back to jumpbox
# }all_db2_nodes}

ssh 192.168.1.20
sudo su

cat <<EOF >~/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
chmod 400 ~/.ssh/config

cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys
scp /root/.ssh/id_dsa 192.168.1.21:/root/.ssh
scp /root/.ssh/id_dsa 192.168.1.40:/root/.ssh
scp /root/.ssh/id_dsa 192.168.1.41:/root/.ssh
scp /root/.ssh/config 192.168.1.21:/root/.ssh
scp /root/.ssh/config 192.168.1.40:/root/.ssh
scp /root/.ssh/config 192.168.1.41:/root/.ssh

# db2_install help : https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0023669.html
#/data1/db2bits/server_t/db2_install -y -b /opt/IBM/db2 -p SERVER -f PURESCALE -t /tmp/db2_install.trc -l /tmp/db2_install.log
# this leads to a GPFS exception. So try the Db2 setup wizard which requires GUI

# install GUI
yum group install -y "Server with GUI"
#check if the following lines are needed
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
firewall-cmd --add-port=3389/tcp --permanent
firewall-cmd --reload

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
yum -y install xrdp 
systemctl start xrdp.service
netstat -antup | grep 3389
# Set XRDP service to automatically start when VM starts
chkconfig xrdp on

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
tentativenum=180410b
/data2/db2bits/server_t/db2setup -l /tmp/db2setup_${tentativenum}.log -t /tmp/db2setup_${tentativenum}.trc
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
'' | Shared disk for data | /dev/sde |
'' | Mount point (Data) | /db2fs/datafs1 |
'' | Shared disk for log | /dev/sdf |
'' | Mount point (Log) | /db2fs/logfs1 |
'' | DB2 Cluster Services Tiebreaker. Device path | /dev/sdg |
Host List | d1 [eth1], d2 [eth1], cf1 [eth1], cf2 [eth1]|
'' | Preferred primary CF | cf1 |
'' | Preferred secondary CF | cf2 |
Response File and Summary | first option | Install DB2 Server Edition with the IBM DB2 pureScale feature and save my settings in a response file
'' | Response file name | /root/db2server.rsp

The full summary reads: 

```
                                        
Product to install:                     	DB2 Server Edition 
Installation type:                      	Custom 
                                        
Previously Installed Components:        
                                        
Components to be installed:             
    Base client support                 	
    Java support                        	
    SQL procedures                      	
    Base server support                 	
    DB2 data source support             	
    ODBC data source support            	
    Teradata data source support        	
    Spatial Extender server support     	
    Scientific Data Sources             	
    JDBC data source support            	
    IBM Software Development Kit (SDK) for Java(TM) 	
    DB2 LDAP support                    	
    DB2 Instance Setup wizard           	
    Structured file data sources        	
    Integrated Flash Copy Support       	
    General Parallel File System (GPFS) 	
    Oracle data source support          	
    Connect support                     	
    Application data sources            	
    Spatial Extender client             	
    SQL Server data source support      	
    Communication support - TCP/IP      	
    Tivoli SA MP                        	
    Base application development tools  	
    DB2 Update Service                  	
    Replication tools                   	
    Sample database source              	
    DB2 Text Search                     	
    Sybase data source support          	
    Informix data source support        	
    Federated Data Access Support       	
    IBM DB2 pureScale Feature           	
    First Steps                         	
    Guardium Installation Manager Client 	
                                        
Languages:                              
    English                             	
        All Products                    	
                                        
Target directory:                       	/opt/ibm/db2/V11.1
                                        
Maximum space required on each host:    	3300 MB
Install IBM Tivoli System Automation for Multiplatforms (Tivoli SA MP): 	Yes 
                                        
DB2 cluster services:                   
    Mount point:                        	/db2sd_1804a
    DB2 cluster services tiebreaker disk device path: 	/dev/sdg
    DB2 cluster file system device path: 	/dev/sdd
                                        
New instances:                          
    Instance name:                      	db2sdin2
        FCM port range:                 	60000-60005
        CF port:                        	56001
        CF Management port:             	56000
        TCP/IP configuration:           	
            Service name:               	db2c_db2sdin2
            Port number:                	50000
        Instance user information:      	
            User name:                  	db2sdin2
            UID:                        	100
            Group name:                 	db2iadm1
            GID:                        	341
            Home directory:             	/home/db2sdin2
        Fenced user information:        	
            User name:                  	db2sdfe2
            UID:                        	101
            Group name:                 	db2fadm1
            GID:                        	342
            Home directory:             	/home/db2sdfe2
                                        
Cluster caching facilities:             
    Preferred primary cluster caching facility: 	cf1
    Preferred secondary cluster caching facility: 	cf2
DB2 members:                            
    d1                                  	
    d2                                  	
                                        
                                        
New Host List:                          
    Host                                	Cluster Interconnect Netname 
    d1                                  	d1
    d2                                  	d2
    cf1                                 	cf1
    cf2                                 	cf2
```


this generated a reponse file (available in this repo: `db2server.rsp`) that can be used for a setup with the response file.

```bash
ssh 192.168.1.20
sudo su

tentativenum=180410a
/data2/db2bits/server_t/db2setup -r /root/db2server.rsp -l /tmp/db2setup_${tentativenum}.log -t /tmp/db2setup_${tentativenum}.trc
```

## Create DB2 database, connect to it from a client

```bash
ssh rhel@$jumpbox
ssh 192.168.1.20
sudo su

# https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0006744.html
# https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0002057.html
/data1/opt/ibm/db2/V11.1/instance/db2icrt -cf cf1 -cfnet cf1 -cf cf2 -cfnet cf2 -m d1 -mnet d1 -m d2 -mnet d2 -instance_shared_dev /dev/sdd -tbdev /dev/sdg -u db2sdfe1 db2sdin1
```
