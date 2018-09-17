#!/bin/bash

githubRepoCloneUrl=git@github.com:benjguin/db2onAzure.git
localGitFolderpath=/mnt/c/dev/_git/GitHub/benjguin

dateid="180917a"

subscription="Azure bengui"
rg="a_${dateid}"
location="westeurope"
deploymentName="deployment_$dateid"
pubKeyPath=~/.ssh/id_rsa.pub
adwinPassword="BHxutbsp82________"
db2bits='https://###obfuscated###.blob.core.windows.net/setup/v11.1_linuxx64_server_t.tar.gz?sv=2016-05-31&sr=b&si=readonly&sig=###obfuscated###'
lisbitsfilename=lis-rpms-4.2.6.tar.gz
lisbits='https://###obfuscated###.blob.core.windows.net/setup/lis-rpms-4.2.4-2.tar.gz?sv=2016-05-31&sr=b&si=readonly&sig=###obfuscated###'
gitrawurl='https://raw.githubusercontent.com/benjguin/db2onAzure/master/'
jumpboxPublicName="j${dateid}"
tempLocalFolder=/mnt/c/afac/
acceleratedNetworkingOnGlusterfs=true
acceleratedNetworkingOnDB2=true
acceleratedNetworkingOnOthers=true

jumpbox="j${dateid}.${location}.cloudapp.azure.com"
echo $jumpbox
