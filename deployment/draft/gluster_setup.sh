#Gluster setup - execute on one node only!

gluster peer probe g1b
gluster peer probe g2b
gluster peer probe g3b

gluster pool list

#create gluster volumes
gluster volume create db2data replica 3 g1b:/bricks/db2data/db2data g2b:/bricks/db2data/db2data g3b:/bricks/db2data/db2data

gluster volume start db2data

mkdir -p /db2/data
mount -t glusterfs g1b:/db2data /db2/data/


#create gluster-block device file
gluster-block create db2data/data ha 3 192.168.1.10,192.168.1.11,192.168.1.12 2480GiB
gluster-block create db2data/quorum ha 3 192.168.1.10,192.168.1.11,192.168.1.12 10GiB
gluster-block create db2data/log ha 3 192.168.1.10,192.168.1.11,192.168.1.12 500GiB
gluster-block create db2data/shared ha 3 192.168.1.10,192.168.1.11,192.168.1.12 10GiB
