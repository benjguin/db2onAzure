#!/bin/bash

# ******** Section 1 : Your private settings  - please edit them as needed ********
# Make sure the settings are working for your private Azure and local Linux setup. Other sections give you advanced control about the deplyoment

# a suffix that is based on the date (yymmdd + a letter from a to z so you have 26 tries a day!). You may prefer to use other means to create resource group or deployment names.
dateid="180921a"

# subscription name or subscription ID
subscription="<my Azure subscription name>"

# Azure region where everything will be deployed
location="westeurope"

# storage account name where the bits are made available for the setup scripts. As created in the "Prepare the Bits" documentation
stor1=db99up01

# local folder where the db2OnAzure git folder is cloned
localGitFolderpath=/mnt/c/Users/myUser/source/

# This local temp folder is where ssh keys for the platform are generated. If you deploy several times, they can be reused from there.
# This folder should exist
tempLocalFolder=/mnt/c/tmp/db2/

# Admin password for the `adwin` accoun on the Window VM
adwinPassword="BHxutbsp82________"

# ******** Section 2 : Prepare the Bits and resource group defaults ********

# Linux Integration Services v4.2 for Hyper-V and Azure bits. The minor version may change so the bits are made available to the scripts with a generic minro version of `x`.
lisbitsgenericfilename=lis-rpms-4.2.x.tar.gz

# Db2 setup file
db2bitsfilename=v11.1_linuxx64_server_t.tar.gz

# Shared access signature to access the LIS bits
lisbitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$lisbitsgenericfilename" --output tsv`

# Full URL where scripts can access the LIS bits
lisbits="https://${stor1}.blob.core.windows.net/setup/${lisbitsgenericfilename}?${lisbitssas}"  

# Shared access signature to access the Db2 bits
db2bitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$db2bitsfilename" --output tsv`

# Full URL where scripts can access the Db2 bits
db2bits="https://${stor1}.blob.core.windows.net/setup/${db2bitsfilename}?${db2bitssas}"

# URL of the GitHub repo where all this code is made available
githubRepoCloneUrl=git@github.com:benjguin/db2onAzure.git

# raw path on GitHub where the ARM templates and scripts will download other ARM templates and scripts
<<<<<<< HEAD
gitrawurl='https://raw.githubusercontent.com/benjguin/db2onAzure/master/'
=======
gitrawurl='https://raw.githubusercontent.com/benjguin/db2onAzure/doc1/'
>>>>>>> 0ef6ada6ce4a5a48b2de3c93adbcb0f9f1afeb2e

# Azure resource group where the Db2 setup will be deployed 
rg="a_${dateid}"

# name under which the Azure deployment will be logged
deploymentName="deployment_$dateid"

# ******** Section 3 : Deployment Options ********

# do you want to use accelerated networking on the GlusterFS nodes?
acceleratedNetworkingOnGlusterfs=true

# do you want to use accelerated networking on the Db2 nodes?
acceleratedNetworkingOnDB2=true

# do you want to use accelerated networking on other nodes (jumpbox, Windows and witness nodes)
acceleratedNetworkingOnOthers=true

# Number of Db2 members in the Db2 pureScale cluster. default is 2.
nbDb2MemberVms=2

# NB: the nbDb2CfVms variable is not set as the deployment as only been tested with the default value of 2, and more would not be supported. 

# ******** Section 4 : Jumpbox defaults ********

# Path to the SSH public key that will be authorized in the jumpbox. Create the key using:
# ssh-keygen -t rsa -b 4096 -C "myaccount@outlook.com"
pubKeyPath=~/.ssh/id_rsa.pub

# DNS name that will be given to the public IP address 
jumpboxPublicName="j${dateid}"

# public URL where the jumbox can be accessed. You can typically connect with ssh rhel@$jumbox 
jumpbox="${jumpboxPublicName}.${location}.cloudapp.azure.com"
echo $jumpbox