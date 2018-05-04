#!/bin/bash

userPubKeyValue=$1
rhelPrivKeyValue=$2
rhelPubKeyValue=$3
rootPrivKeyValue=$4
rootPubKeyValue=$5

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ `hostname` == "jumpbox" ]
then
    echo $userPubKeyValue >> /root/.ssh/authorized_keys
else
    sudo -n -u root -s bash setsshkeys_root.sh "$rootPrivKeyValue" "rootPubKeyValue"
fi

echo $rhelPubKeyValue >> ~/.ssh/authorized_keys
echo $rhelPrivKeyValue > ~/.ssh/id_rsa
echo $rhelPubKeyValue > ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
