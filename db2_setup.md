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
mount /dev/sdc1 /data1 # TODO: have to make that persistent
cat >> /etc/fstab << EOF

/dev/sdc1   /data1  auto    defaults,nofail 0   2
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
PasswordAuthentication no
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
# }all_db2_nodes}


```