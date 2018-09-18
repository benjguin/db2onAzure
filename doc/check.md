# Check the setup and troubleshoot

```bash
source init.sh
```

You can connect to the infrastructure with the following command line:

```bash
ssh rhel@$jumpbox
```

NB: in that case, no key is provided because `init.sh` uses the default key (`pubKeyPath=~/.ssh/id_rsa.pub`). 
Should you have defined another key, you would have to use `ssh -i <private_key_file> rhel@$jumpbox` instead.

From the jumpbox, you can see available nodes in `/etc/hosts` and connect to the nodes. 
Here is an example:

```
[rhel@jumpbox ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.5 jumpbox
192.168.0.40 wcli0
192.168.0.60 witn0
192.168.0.20 d0
192.168.0.21 d1
192.168.0.30 cf0
192.168.0.31 cf1
192.168.0.10 g0
192.168.0.11 g1
192.168.0.12 g2
[rhel@jumpbox ~]$ ssh d0
Last login: Tue Sep 18 07:27:42 2018 from 192.168.0.5
[rhel@d0 ~]$
```


Here is a list of log files you want to check:

File name | nodes | logs the execution of ... 
----------|-------|---------------------------
/tmp/custom-scripts-from-ARM.log | jumpbox, d*, cf*, g* | custom scripts during the ARM deployment
/tmp/postARM.log | jumpbox | scripts executed in the post ARM phase of the deployment (cd [deploy](deploy.md) for an explanation on these phases). 
/tmp/postARM-prepare-an.log | jumpbox | In the post ARM phase, nodes must be prepared before setting accelerated networking. This is what the [fromjumpbox-prepare-an.sh](../deployment/postARMscripts/fromjumpbox-prepare-an.sh) script does.
/tmp/db2setup_001.log | d0 | the actual DB2 setup, which may contain additional links to other log files.

Once you've checked that the logs look good, connect to the deployed nodes to further check the state of the system.

Here is a typical routine:

```bash
ssh rhel@$jumpbox
ssh d0

# sudo su may generate a warning you can ignore:
# ABRT has detected 1 problem(s). For more info run: abrt-cli list
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

## Troubleshoot

For troubleshooting, please check the [KB](KB.md).

DISK STRUCTURE