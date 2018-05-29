#!/bin/bash

nbDb2MemberVms=$1
nbDb2CfVms=$2
lisbits=$3

nbGlusterfsVms=3

db2servers=()
for (( i=0; i<$nbDb2MemberVms; i++ ))
do
    db2servers+=(192.168.0.2$i)
done

for (( i=0; i<$nbDb2MemberVms; i++ ))
do
    db2servers+=(192.168.0.3$i)
done

# reboot DB2 servers so that they have the right kernel
for db2srv in "${db2servers[@]}"
do
    ssh $db2srv sudo shutdown -r now
done

# wait for the reboots to finish
source /tmp/wait4reboots_src.sh

echo "lisbits=$lisbits"

for db2srv in "${db2servers[@]}"
do
    scp /tmp/fromdcfan_root.sh ${db2srv}:/tmp/
    ssh $db2srv "sudo bash -v /tmp/fromdcfan_root.sh \"$lisbits\""
done

# need to wait for the reboot to finsih before deallocating and set accelerated network to true
source /tmp/wait4reboots_src.sh
