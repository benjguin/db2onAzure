#!/bin/bash

nbDb2MemberVms=$1
nbDb2CfVms=$2
lisbits=$4

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

echo "lisbits=$lisbits"

for db2srv in "${db2servers[@]}"
do
    scp /tmp/fromdcfan_root.sh ${db2srv}:/tmp/
    ssh $db2srv sudo bash -v /tmp/fromdcfan_root.sh "$lisbits"
done

