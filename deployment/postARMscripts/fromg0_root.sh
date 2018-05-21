#Gluster setup - execute on one node only!

gluster peer probe g0b
gluster peer probe g1b
gluster peer probe g2b

gluster pool list

stay="true"
tries=0
while [ "$stay" == "true" ]
do
    gluster peer status
    x=`gluster peer status | grep "Peer in Cluster" | wc -l`
    if [ "$x" == "2" ]
    then
        stay="false"
    else
        if [ $tries -gt 10 ]
        then
            echo "Gluster FS cluster failed to start correctly"
            exit 1
        fi
        echo "waiting for 30 seconds ..."
        sleep 30s
        ((tries=tries+1))
    fi
done

#create gluster volumes
gluster volume create db2data replica 3 g0b:/bricks/db2data/db2data g1b:/bricks/db2data/db2data g2b:/bricks/db2data/db2data

gluster volume start db2data

mkdir -p /db2/data
mount -t glusterfs g0b:/db2data /db2/data/


#create gluster-block device file
gluster-block create db2data/data ha 3 192.168.1.10,192.168.1.11,192.168.1.12 2480GiB
gluster-block create db2data/quorum ha 3 192.168.1.10,192.168.1.11,192.168.1.12 10GiB
gluster-block create db2data/log ha 3 192.168.1.10,192.168.1.11,192.168.1.12 500GiB
gluster-block create db2data/shared ha 3 192.168.1.10,192.168.1.11,192.168.1.12 10GiB
