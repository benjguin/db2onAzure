#!/bin/bash

userPubKeyValue=$1
rhelPrivKeyValue=$2
rhelPubKeyValue=$3
rootPrivKeyValue=$4
rootPubKeyValue=$5
logPath=$6

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bash -v ${DIR}/startnetwork_root.sh &> >(tee -a $logPath)
bash -v ${DIR}/setsshkeys_root.sh "$userPubKeyValue" "$rhelPrivKeyValue" "$rhelPubKeyValue" "$rootPrivKeyValue" "$rootPubKeyValue" &> >(tee -a $logPath)
