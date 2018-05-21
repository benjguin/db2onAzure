#!/bin/bash

# sample output:
# [root@d1 rhel]# fdisk -l | grep /dev/mapper/3
# Disk /dev/mapper/36001405149ee39c319845aaa710099a7: 2662.9 GB, 2662879723520 bytes, 5200936960 sectors
# Disk /dev/mapper/36001405484ba6ab80934f2290a2b579f: 10.7 GB, 10737418240 bytes, 20971520 sectors
# Disk /dev/mapper/36001405bfc71ff861174f2bbb0bfea37: 536.9 GB, 536870912000 bytes, 1048576000 sectors
# Disk /dev/mapper/36001405645b2e72c56142ef97932cb95: 10.7 GB, 10737418240 bytes, 20971520 sectors

# iSCSI servers were configured since service was configured
multipath -l
iscsiadm -m discovery -t sendtargets -p 192.168.1.10
iscsiadm -m node -L automatic 
iscsiadm -m session 
multipath -l
sleep 5s
fdisk -l | grep /dev/mapper/3
ls -ls /dev/mapper

wwiddb2data1=`fdisk -l | grep /dev/mapper/3 | grep ': 2' | awk '{sub(/\/dev\/mapper\//,""); sub(/:/,""); print $2}'`
wwiddb2log1=`fdisk -l | grep /dev/mapper/3 | grep ': 5' | awk '{sub(/\/dev\/mapper\//,""); sub(/:/,""); print $2}'`
wwiddb2shared=`fdisk -l | grep /dev/mapper/3 | grep ': 1' | head -1 | awk '{sub(/\/dev\/mapper\//,""); sub(/:/,""); print $2}'`
wwiddb2tieb=`fdisk -l | grep /dev/mapper/3 | grep ': 1' | tail -1 | awk '{sub(/\/dev\/mapper\//,""); sub(/:/,""); print $2}'`

cat > /tmp/initwwids.sh <<EOF
wwiddb2data1=$wwiddb2data1
wwiddb2log1=$wwiddb2log1
wwiddb2shared=$wwiddb2shared
wwiddb2tieb=$wwiddb2tieb
EOF
