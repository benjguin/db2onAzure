#!/bin/bash

userPubKeyValue=$1
rhelPrivKeyValue=$2
rhelPubKeyValue=$3
rootPrivKeyValue=$4
rootPubKeyValue=$5

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo -n -u root -s bash ${DIR}/startnetwork.sh

bash ${DIR}/setsshkeys.sh "$userPubKeyValue" "$rhelPrivKeyValue" "$rhelPubKeyValue" "$rootPrivKeyValue" "$rootPubKeyValue"

sudo -n -u root -s bash ${DIR}/installconfiggluster_root
