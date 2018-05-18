#!/bin/bash

userPubKeyValue=$1
rhelPrivKeyValue=$2
rhelPubKeyValue=$3
rootPrivKeyValue=$4
rootPubKeyValue=$5
db2bits=$6

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo -n -u root bash -c "bash -v ${DIR}/startnetwork_root.sh"

bash -v ${DIR}/setsshkeys.sh "$userPubKeyValue" "$rhelPrivKeyValue" "$rhelPubKeyValue" "$rootPrivKeyValue" "$rootPubKeyValue"

sudo -n -u root bash -c "bash -v ${DIR}/db2_root.sh \"$db2bits\""
