#/bin/bash

#client
yum -y install device-mapper-multipath iscsi-initiator-utils
modprobe dm_multipath
systemctl start multipathd
systemctl enable multipathd

cat >> /etc/multipath.conf <<EOF
# LIO iSCSI
devices {
        device {
                vendor "LIO-ORG"
                user_friendly_names "yes" # names like mpatha
                path_grouping_policy "failover" # one path per group
                path_selector "round-robin 0"
                path_checker "tur"
                prio "const"
                rr_weight "uniform"
        }
}
EOF

systemctl start multipathd
systemctl enable multipathd

iscsiadm --mode discovery --type sendtargets --portal 192.168.1.10 -l

for device in {a,b,c,d}; do mkfs.xfs /dev/mapper/mpath$device; done


mkdir -p /db2/{data,quorum,shared,logs}

# iscsiadm -m session
# iscsiadm --mode node --logoutall=all
