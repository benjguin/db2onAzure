#!/bin/bash

userPubKeyValue=$1
rhelPrivKeyValue=$2
rhelPubKeyValue=$3
rootPrivKeyValue=$4
rootPubKeyValue=$5

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat > /home/rhel/.ssh/config << 'EOF' 
Host *
    StrictHostKeyChecking no
EOF
chown rhel:rhel /home/rhel/.ssh/config
chmod 400 /home/rhel/.ssh/config

echo "$rhelPubKeyValue" >> /home/rhel/.ssh/authorized_keys
echo "$rhelPrivKeyValue" | base64 -d > /home/rhel/.ssh/id_rsa
echo "$rhelPubKeyValue" > /home/rhel/.ssh/id_rsa.pub
chown rhel:rhel /home/rhel/.ssh/authorized_keys
chown rhel:rhel /home/rhel/.ssh/id_rsa
chown rhel:rhel /home/rhel/.ssh/id_rsa.pub
chmod 600 /home/rhel/.ssh/id_rsa
chmod 644 /home/rhel/.ssh/id_rsa.pub

if [ "$rootPrivKeyValue" != "x" ]
then
    nbfound=`ls -d /root/.ssh | wc -l`
    if [ "$nbfound" == "0" ]
    then
        mkdir /root/.ssh
    fi

    chmod 700 /root/.ssh

    cat > /root/.ssh/config << 'EOF' 
Host *
    StrictHostKeyChecking no
EOF
    chmod 400 /root/.ssh/config

    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "$rootPubKeyValue" >> /root/.ssh/authorized_keys
    echo "$rootPrivKeyValue" | base64 -d > /root/.ssh/id_rsa
    echo "$rootPubKeyValue" > /root/.ssh/id_rsa.pub
    chmod 600 /root/.ssh/id_rsa
    chmod 644 /root/.ssh/id_rsa.pub
fi



