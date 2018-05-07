#!/bin/bash

rootPrivKeyValue=$1
rootPubKeyValue=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir /root/.ssh
chmod 700 /root/.ssh
cat > /root/.ssh/config << 'EOF' 
Host *
    StrictHostKeyChecking no
EOF
chmod 400 /root/.ssh/config
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo $rootPubKeyValue >> /root/.ssh/authorized_keys
echo $rootPrivKeyValue > /root/.ssh/id_rsa
echo $rootPubKeyValue > /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
