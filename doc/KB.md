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

Here is a typical routine 

```bash
ssh rhel@$jumpbox
ssh d0
sudo su

/data1/db2/bin/db2cluster -cfs -list 
/data1/db2/bin/db2cluster -cfs -list -filesystem
/usr/lpp/mmfs/bin/mmgetstate -a
/usr/lpp/mmfs/bin/mmlscluster
lsrpdomain
```

if everything is good, move to the second checks:

```bash
ssh rhel@$jumpbox
ssh d0
sudo su
netstat -an | grep 50000
ssh d1
netstat -an | grep 50000
```

if the service doesn't appear to be running on d1, you can try restarting it manually:

```bash
sudo su - db2sdin1
db2start
exit
netstat -an | grep 50000
```

sample outputs:

```
[rhel@d1 ~]$ /usr/lpp/mmfs/bin/mmlscluster

GPFS cluster information
========================
  GPFS cluster name:         db2cluster_20180530143037.d0
  GPFS cluster id:           5013913813214213519
  GPFS UID domain:           db2cluster_20180530143037.d0
  Remote shell command:      /var/db2/db2ssh/db2locssh
  Remote file copy command:  /var/db2/db2ssh/db2scp
  Repository type:           server-based

GPFS cluster configuration servers:
-----------------------------------
  Primary server:    d0
  Secondary server:  d1

 Node  Daemon node name  IP address    Admin node name  Designation
--------------------------------------------------------------------
   1   d0                192.168.0.20  d0               quorum-manager
   2   d1                192.168.0.21  d1               quorum-manager
   3   cf0               192.168.0.30  cf0              quorum-manager
   4   cf1               192.168.0.31  cf1              quorum-manager

[rhel@d1 ~]$ lsrpdomain
Name                     OpState RSCTActiveVersion MixedVersions TSPort GSPort
db2domain_20180530143017 Online  3.2.1.2           No            12347  12348
[rhel@d1 ~]$ sudo su
ABRT has detected 1 problem(s). For more info run: abrt-cli list
[root@d1 rhel]# whoami
root
[root@d1 rhel]# /data1/db2/bin/db2cluster -cfs -list
Domain Name: db2cluster_20180530143037.d0
[root@d1 rhel]# /data1/db2/bin/db2cluster -cfs -list -filesystem
FILE SYSTEM NAME                       MOUNT POINT
---------------------------------      -------------------------
db2fs1                                 /db2sd_1804a
[root@d1 rhel]# /usr/lpp/mmfs/bin/mmgetstate -a

 Node number  Node name        GPFS state
------------------------------------------
       1      d0               active
       2      d1               active
       3      cf0              active
       4      cf1              active
[root@d1 rhel]# /usr/lpp/mmfs/bin/mmlscluster

GPFS cluster information
========================
  GPFS cluster name:         db2cluster_20180530143037.d0
  GPFS cluster id:           5013913813214213519
  GPFS UID domain:           db2cluster_20180530143037.d0
  Remote shell command:      /var/db2/db2ssh/db2locssh
  Remote file copy command:  /var/db2/db2ssh/db2scp
  Repository type:           server-based

GPFS cluster configuration servers:
-----------------------------------
  Primary server:    d0
  Secondary server:  d1

 Node  Daemon node name  IP address    Admin node name  Designation
--------------------------------------------------------------------
   1   d0                192.168.0.20  d0               quorum-manager
   2   d1                192.168.0.21  d1               quorum-manager
   3   cf0               192.168.0.30  cf0              quorum-manager
   4   cf1               192.168.0.31  cf1              quorum-manager

[root@d1 rhel]# lsrpdomain
Name                     OpState RSCTActiveVersion MixedVersions TSPort GSPort
db2domain_20180530143017 Online  3.2.1.2           No            12347  12348
[root@d1 rhel]#
```


```
ssh rhel@$jumpbox
[rhel@jumpbox ~]$ ssh d0
Warning: Permanently added 'd0' (ECDSA) to the list of known hosts.
[rhel@d0 ~]$ netstat -an | grep 50000
tcp        0      0 0.0.0.0:50000           0.0.0.0:*               LISTEN
[rhel@d0 ~]$ logout
Connection to d0 closed.
[rhel@jumpbox ~]$ ssh d1
Warning: Permanently added 'd1' (ECDSA) to the list of known hosts.
[rhel@d1 ~]$ netstat -an | grep 50000
[rhel@d1 ~]$ sudo su - db2sdin1
Last login: Wed May 30 14:43:01 UTC 2018
[db2sdin1@d1 ~]$ db2start
SQL8007W  There are "89" day(s) left in the evaluation period for the product
"DB2 Advanced Enterprise Server Edition". For evaluation license terms and
conditions, refer to the License Agreement document located in the license
directory in the installation path of this product. If you have licensed this
product, ensure the license key is properly registered. You can register the
license by using the db2licm command line utility. The license key can be
obtained from your licensed product CD.
05/30/2018 15:03:17     0   0   SQL1026N  The database manager is already active.
05/30/2018 15:03:27     1   0   SQL1063N  DB2START processing was successful.
SQL6032W  Start command processing was attempted on "2" node(s).  "1" node(s) were successfully started.  "1" node(s) were already started.  "0" node(s) could not be started.
[db2sdin1@d1 ~]$ logout
[rhel@d1 ~]$ netstat -an | grep 50000
tcp        0      0 0.0.0.0:50000           0.0.0.0:*               LISTEN
[rhel@d1 ~]$
```

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
