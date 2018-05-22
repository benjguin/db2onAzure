#!/bin/bash

nbDb2MemberVms=$1
nbDb2CfVms=$2

nbGlusterfsVms=3

scp /tmp/fromg0_root.sh 192.168.0.10:/tmp/
ssh 192.168.0.10 sudo -n -u root -s "bash -v /tmp/fromg0_root.sh"

for (( i=0; i<$nbGlusterfsVms; i++ ))
do
    sudo bash -c "echo \"192.168.0.1${i} g${i}\" >> /etc/hosts" 
done

sudo bash -c "echo \"192.168.0.5 jumpbox\" >> /etc/hosts" 
sudo bash -c "echo \"192.168.0.40 wcli0\" >> /etc/hosts" 
sudo bash -c "echo \"192.168.0.60 witn0\" >> /etc/hosts" 

db2servers=()
for (( i=0; i<$nbDb2MemberVms; i++ ))
do
    db2servers+=(192.168.0.2$i)
    sudo bash -c "echo \"192.168.0.2${i} d${i}\" >> /etc/hosts" 
done

for (( i=0; i<$nbDb2MemberVms; i++ ))
do
    db2servers+=(192.168.0.3$i)
    sudo bash -c "echo \"192.168.0.3${i} cf${i}\" >> /etc/hosts" 
done

cat > /tmp/tmpcmd001.sh <<EOF
sudo -n -u root bash -c "fdisk -l | grep /dev/mapper/3 > /tmp/iscsidisks.txt"
EOF
scp /tmp/tmpcmd001.sh 192.168.0.20:/tmp/
ssh 192.168.0.20 bash /tmp/tmpcmd001.sh
scp 192.168.0.20:/tmp/iscsidisks.txt .

scp /tmp/fromd0getwwids_root.sh 192.168.0.20:/tmp/

ssh 192.168.0.20 sudo -n -u root -s "bash -v /tmp/fromd0getwwids_root.sh"
scp 192.168.0.20:/tmp/initwwids.sh /tmp/initwwids.sh
source /tmp/initwwids.sh

cat > /tmp/tmpcmd002.sh <<EOF
cat >> /etc/multipath.conf <<EOF2
multipaths {
    multipath {
        wwid  ${wwiddb2data1}
        alias db2data1  
    }
    multipath {
        wwid  ${wwiddb2log1}
        alias db2log1  
    }
    multipath {
        wwid  ${wwiddb2shared}
        alias db2shared
    }
    multipath {
        wwid  ${wwiddb2tieb}
        alias db2tieb 
    }
}
EOF2

iscsiadm -m discovery -t sendtargets -p 192.168.1.10
iscsiadm -m node -L automatic 
iscsiadm -m session 
multipath -l
sleep 5s
fdisk -l | grep /dev/mapper/3
lsblk
ls -ls /dev/mapper

sudo shutdown -r now
EOF

for db2srv in "${db2servers[@]}"
do
    scp /tmp/tmpcmd002.sh ${db2srv}:/tmp/
    ssh $db2srv bash /tmp/tmpcmd002.sh
done

# wait for the reboots to finish
for db2srv in "${db2servers[@]}"
do
    echo "waiting for $db2srv to reboot"
    stay="true"
    tries=0
    while [ "$stay" == "true" ]
    do
        ssh $db2srv whoami
        x=`ssh $db2srv whoami | grep rhel | wc -l`
        if [ "$x" == "1" ]
        then
            stay="false"
        else
            if [ $tries -gt 10 ]
            then
                echo "Servers did not reboot correctly"
                exit 1
            fi
            echo "waiting for 30 seconds ..."
            sleep 30s
            ((tries=tries+1))
        fi
    done
done

scp /tmp/fromd0_root.sh 192.168.0.20:/tmp/

cat > /tmp/tmpcmd003.sh <<EOF
sudo -n -u root bash -c "bash -v /tmp/fromd0_root.sh \"$nbDb2MemberVms\" \"$nbDb2CfVms\""
EOF

cat /tmp/tmpcmd003.sh
scp /tmp/tmpcmd003.sh 192.168.0.20:/tmp/
ssh 192.168.0.20 bash /tmp/tmpcmd003.sh
