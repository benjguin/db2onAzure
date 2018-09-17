#!/bin/bash

# a suffix that is based on the date (yymmdd + a letter from a to z so you have 26 tries a day!). You may prefer to use other means to create resource group or deployment names.
dateid="180917a"

subscription="Azure bengui"
stor1=db27up34
adwinPassword="BHxutbsp82________"
location="westeurope"
localGitFolderpath=/mnt/c/dev/GitHub/benjguin

#lisbitsfilename=lis-rpms-4.2.6.tar.gz
lisbitsgenericfilename=lis-rpms-4.2.x.tar.gz
db2bitsfilename=v11.1_linuxx64_server_t.tar.gz
lisbitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$lisbitsgenericfilename" --output tsv`
db2bitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$db2bitsfilename" --output tsv`
lisbits="https://${stor1}.blob.core.windows.net/setup/${lisbitsgenericfilename}?${lisbitssas}"
db2bits="https://${stor1}.blob.core.windows.net/setup/${db2bitsfilename}?${db2bitssas}"

githubRepoCloneUrl=git@github.com:benjguin/db2onAzure.git

rg="a_${dateid}"
deploymentName="deployment_$dateid"
pubKeyPath=~/.ssh/id_rsa.pub
gitrawurl='https://raw.githubusercontent.com/benjguin/db2onAzure/master/'
jumpboxPublicName="j${dateid}"
tempLocalFolder=/mnt/c/afac/
acceleratedNetworkingOnGlusterfs=true
acceleratedNetworkingOnDB2=true
acceleratedNetworkingOnOthers=true

jumpbox="j${dateid}.${location}.cloudapp.azure.com"
echo $jumpbox
