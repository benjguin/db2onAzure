# Deploy

The [deployment script](../deployment/deploy.sh) needs a number of variables we have to prepare. 
Here is the list (excerpt from the usage part of the script):
- subscription (-s): Azure subscription name"
- resourceGroupName (-g): Azure resource group name"
- location (-l): Azure region where the resources will be created"
- deploymentName (-n): Azure region where the resources will be created"
- pubKeyPath (-k): path to the public key to be used for jumpbox access"
- adwinPassword (-p): password for the 'adwin' user on Windows boxes"
- db2bits (-d): location where the 'v11.1_linuxx64_server_t.tar.gz' file can be downloaded from. You should manually download it from https://www.ibm.com/analytics/us/en/db2/trials/ first, then copy it somewhere like on Azure storage."
- gitrawurl (-u): folder where this repo is, with a trailing /. E.g.: https://raw.githubusercontent.com/benjguin/db2onAzure/master/"
- jumpboxPublicName (-j): jumpbox public DNS name. The full DNS name will be <jumpboxPublicName>.<location>.cloudapp.azure.com."
- temp local folder (-t) for ssh keys and other files, with a trailing /."
- acceleratedNetworkingOnGlusterfs (-a). Should the Gluster FS NICs have accelerated networking enabled? Possible values: true or false."
- acceleratedNetworkingOnDB2 (-c). Should the DB2 NICs have accelerated networking enabled? Possible values: true or false."
- acceleratedNetworkingOnOthers (-e). Should the other NICs have accelerated networking enabled? Possible values: true or false."
- lisbits (-b). location where the 'lis-rpms-4.2.4-2.tar.gz' file can be downloaded from. You can first manually download it from https://www.microsoft.com/en-us/download/details.aspx?id=55106"
- nbDb2MemberVms (-y) - nb of DB2 member VMs - default is 2"
- nbDb2CfVms (-z) - nb of DB2 caching facilities (CF) VMs - default and recommended value is 2 (the deployment was not tested with less and may not be supported with 3 or more as there is only 1 primary CF role and 1 secondary CF role)"


## init the variables

```
source 01init.sh
```

## Run the deployment script

```bash
cd $localGitFolderpath/db2OnAzure/deployment
./deploy.sh -s "$subscription" -g "$rg" -l "$location" -n "$deploymentName" -k "$pubKeyPath" -p "$adwinPassword" -d "$db2bits" -u "$gitrawurl" -j "$jumpboxPublicName" -t "$tempLocalFolder" -a "$acceleratedNetworkingOnGlusterfs" -c "$acceleratedNetworkingOnDB2" -e "$acceleratedNetworkingOnOthers" -b "$lisbits"
```

