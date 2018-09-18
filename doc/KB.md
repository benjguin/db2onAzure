# Knowledge Base

Known issues and fixes or diagnostics path

## KB016 - A few commands to check the state of the cluster, or remove uninstalled components

<https://www.ibm.com/developerworks/data/library/techarticle/dm-1011db2purescalefeature/>

```
/data1/db2/bin/db2cluster -cfs -list 
/data1/db2/bin/db2cluster -cfs -list -filesystem
/usr/lpp/mmfs/bin/mmgetstate -a
/usr/lpp/mmfs/bin/mmlscluster
lsrpdomain
```

from [How to remove a TSA peer domain](http://www.dba-db2.com/2016/02/how-to-remove-a-tsa-peer-domain.html)

```
lsrpdomain
rmrpdomain db2domain_20180417160454
```

## KB017 - After the installation, check and start remaining nodes


## KB018 - Azure Quota Exceeded

Error Code: QuotaExceeded

Message: Operation results in exceeding quota limits of Core. Maximum allowed: 100, Current in use: 61, Additional requested: 50. Please read more about quota increase at http://aka.ms/corequotaincrease.

Here is an example 

```
myuser:/mnt/c/dev/GitHub/benjguin/db2OnAzure/deployment$ ./deploy.sh -s "$subscription" -g "$rg" -l "$location" -n "$deploymentName" -k "$pubKeyPath" -p "$adwinPassword" -d "$db2bits" -u "$gitrawurl" -j "$jumpboxPublicName" -t "$tempLocalFolder" -a "$acceleratedNetworkingOnGlusterfs" -c "$acceleratedNetworkingOnDB2" -e "$acceleratedNetworkingOnOthers" -b "$lisbits" -y $nbDb2MemberVms
Resource group 'a_180917c' could not be found.
Resource group with name a_180917c could not be found. Creating new resource group..
+ az group create --name a_180917c --location westeurope
reusing ssh key files available in folder /mnt/c/afac/
Starting deployment...
Azure Error: InvalidTemplateDeployment
Message: The template deployment 'deployment_180917c' is not valid according to the validation procedure. The tracking id is '6bcdf###obfuscated###bb79'. See inner errors for details. Please see https://aka.ms/arm-deploy for usage details.
Exception Details:
        Error Code: QuotaExceeded
        Message: Operation results in exceeding quota limits of Core. Maximum allowed: 100, Current in use: 61, Additional requested: 50. Please read more about quota increase at http://aka.ms/corequotaincrease.
Template was NOT successfully deployed
```

This happens when the deployment will result in more cores than allowed in the Azure subscription. Typical reasons are:
- the subscription doesn't have enough core to deploy one instance of the Db2 pureScale. In that case, [ask for quota increase](http://aka.ms/corequotaincrease) or use another subscription.
- **you are in the process of deleting a previous deployment's resource group which still consumes quota**. In that case, just wait for the resource group to be completely deleted.

## KB019 - DB2 The transaction log for the database is full

[Resolving "The transaction log for the database is full" error](http://www-01.ibm.com/support/docview.wss?uid=swg21472442)

## Other articles in the KB archive

You may find other articles in the [KB archive](archive/KB_archive.md).
