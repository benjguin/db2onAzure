#!/bin/bash

# a suffix that is based on the date (yymmdd + a letter from a to z so you have 26 tries a day!). You may prefer to use other means to create resource group or deployment names.
if [ -z $dateid ]; then
    dateid="180918a"
fi

# subscription name or subscription ID
subscription="Azure bengui"

# storage account name where the bits are made available for the setup scripts
stor1=db27up34

# Admin password for the `adwin` accoun on the Window VM
adwinPassword="BHxutbsp82________"

# Azure region where everything will be deployed
location="westeurope"

# local folder where the db2OnAzure git folder is cloned
localGitFolderpath=/mnt/c/dev/GitHub/benjguin

# Linux Integration Services v4.2 for Hyper-V and Azure bits. The minor version may change so the bits are made available to the scripts with a generic minro version of `x`.
lisbitsgenericfilename=lis-rpms-4.2.x.tar.gz

# Db2 setup file
db2bitsfilename=v11.1_linuxx64_server_t.tar.gz

#allows to use other url 
if [ -z $lisbits ]; then
    # Shared access signature to access the LIS bits
    lisbitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$lisbitsgenericfilename" --output tsv`
    # Full URL where scripts can access the LIS bits
    lisbits="https://${stor1}.blob.core.windows.net/setup/${lisbitsgenericfilename}?${lisbitssas}"  
fi
if [ -z $db2bits ]; then
    # Shared access signature to access the Db2 bits
    db2bitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$db2bitsfilename" --output tsv`
    # Full URL where scripts can access the Db2 bits
    db2bits="https://${stor1}.blob.core.windows.net/setup/${db2bitsfilename}?${db2bitssas}"
fi

# URL of the GitHub repo where all this code is made available
githubRepoCloneUrl=git@github.com:benjguin/db2onAzure.git

# raw path on GitHub where the ARM templates and scripts will download other ARM templates and scripts
gitrawurl='https://raw.githubusercontent.com/benjguin/db2onAzure/doc1/'

# Azure resource group where the Db2 setup will be deployed 
rg="a_${dateid}"

# name under which the Azure deployment will be logged
deploymentName="deployment_$dateid"

# Path to the SSH public key that will be authorized in the jumpbox
pubKeyPath=~/.ssh/id_rsa.pub

# This local temp folder is where ssh keys for the platform are generated. If you deploy several times, they can be reused from there.
# This folder should exist
tempLocalFolder=/mnt/c/afac/

# do you want to use accelerated networking on the GlusterFS nodes?
acceleratedNetworkingOnGlusterfs=true

# do you want to use accelerated networking on the Db2 nodes?
acceleratedNetworkingOnDB2=true

# do you want to use accelerated networking on other nodes (jumpbox, Windows and witness nodes)
acceleratedNetworkingOnOthers=true

# Number of Db2 members in the Db2 pureScale cluster. default is 2.
nbDb2MemberVms=2

# NB: the nbDb2CfVms variable is not set as the deployment as only been tested with the default value of 2, and more would not be supported. 

# DNS name that will be given to the public IP address 
jumpboxPublicName="j${dateid}"

# public URL where the jumbox can be accessed. You can typically connect with ssh rhel@$jumbox 
jumpbox="${jumpboxPublicName}.${location}.cloudapp.azure.com"
echo $jumpbox
