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
# TODO routes need to be checked

dhclient # TODO this has to be executed at startup time

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
scp root_id_dsa.pub rhel@192.168.1.21:/home/rhel/
ssh 192.168.1.21
sudo su
cat /home/rhel/root_id_dsa.pub >> /root/.ssh/authorized_keys
cat >> /etc/ssh/sshd_config << EOF

PermitRootLogin yes
PasswordAuthentication no
EOF
dhclient

exit
exit
# back to jumpbox

ssh 192.168.1.20
sudo su
ssh -o StrictHostKeyChecking=no 192.168.1.21
# could connect from d1 to d2 as root
exit
exit
exit
# back to jumpbox


```