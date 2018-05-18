#!/bin/bash

userPubKeyValue=$1
rhelPrivKeyValue=$2
rhelPubKeyValue=$3
rootPrivKeyValue=$4
rootPubKeyValue=$5

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat > ~/.ssh/config << 'EOF' 
Host *
    StrictHostKeyChecking no
EOF
chmod 400 ~/.ssh/config

echo $rhelPubKeyValue >> ~/.ssh/authorized_keys
echo $rhelPrivKeyValue > ~/.ssh/id_rsa
echo $rhelPubKeyValue > ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

if [ `hostname` != "jumpbox" ]
then
    sudo -n -u root bash -c "bash -v setsshkeys_root.sh \"$rootPrivKeyValue\" \"rootPubKeyValue\""
fi
