# Knowledge Base

Known issues and fixes or diagnostics path

## Network related issues

### need to have a witness node

```
ERROR: A reachable IP address could not be automatically determined that did
not belong to one of the hosts in the DB2 pureScale instance. There may be a
problem with the network adapters gateway IP address or with the hosts network
connection. Verify connectivity for the hosts and manually edit the
configuration file /var/ct/cfg/netmon.cf on each host to include an IP on the
network outside of the DB2 pureScale instance that can be reached by the ping
command so that DB2 may ensure network connectivity. Hosts: "eth1 virbr0
d1:eth1 d1:virbr0eth1 d2:eth1eth1 cf1:eth1eth1 cf2:eth1". The format of
/var/ct/cfg/netmon.cf lines is as follows:  !REQD eth1 9.26.123.245
```

on each node (d1, d2, cf1, cf2): 

```bash
mkdir -p /var/ct/cfg/
# define the witness. cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0061581.html
cat <<EOF > /var/ct/cfg/netmon.cf
!IBQPORTONLY !ALL
!REQD eth0 192.168.1.30
!REQD eth1 192.168.3.60
EOF

nbnics=`ls -als /sys/class/net/  | grep eth | wc -l`
if [ $nbnics == 3 ]
then
cat <<EOF >> /var/ct/cfg/netmon.cf
!REQD eth2 192.168.4.60
EOF
fi
cat /var/ct/cfg/netmon.cf
```

## GPFS related issues

### GPL compilation

```
WARNING: An error occurred while compiling IBM General Parallel File System
(GPFS) Portability Layer (GPL) on host "d1". Return code "3". GPL compilation
log file location  "/tmp/compileGPL.log.002". The GPFS file system cannot be
mounted properly until the GPL module is successfully compiled on this host.
For details, see the specified GPL compilation log. After fixing the problems
shown in the log file, re-run the DB2 installer. For information regarding the
GPFS GPL module compile, see DB2 Information Center.
```

To compile manually: 

```bash
cd /usr/lpp/mmfs/src
mv config/env.mcr config/env.mcr.old
make Autoconfig
make World
make InstallImages
make rpm
```

usually, this is related to the kernel used.

```bash
uname -r
ls -als /lib/modules/
ls -als /lib/modules/`uname -r`/
```

### how to boot to a specific kernel version

- <https://access.redhat.com/solutions/186763>
- <https://access.redhat.com/solutions/1605183>

the code we use on d1, d2, cf1 and cf2 is the following: 

```bash
uname -r
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
# please do **not** point to Red Hat Enterprise Linux Server (3.10.0-514.28.1.el7.x86_64) 7.3 (Maipo)
grub2-set-default 'Red Hat Enterprise Linux Server (3.10.0-514.el7.x86_64) 7.3 (Maipo)'
cat /boot/grub2/grubenv |grep saved
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg


reboot
```

## GPFS is in use - try to drop recreate the iSCSI disks

```
The disk is not available as a free disk for a file system.  A concurrent create file system or add disk to file system may have been run wi
th the same disk.
DATA #2 : String, 8 bytes
/dev/sdd
```

```
[root@d1 V11.1]# fdisk /dev/sdd
WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p

Disk /dev/sdd: 107.4 GB, 107374182400 bytes, 209715200 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: gpt
Disk identifier: 6915D118-6850-45EF-8E7C-EE52311E4B74


#         Start          End    Size  Type            Name
 1           48    209715151    100G  IBM General Par GPFS:

Command (m for help): d
Selected partition 1
Partition 1 is deleted

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

[root@d1 src]# lsblk
NAME                                   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
fd0                                      2:0    1    4K  0 disk
sda                                      8:0    0   32G  0 disk
├─sda1                                   8:1    0  500M  0 part  /boot
└─sda2                                   8:2    0 31.5G  0 part  /
sdb                                      8:16   0   28G  0 disk
├─sdb1                                   8:17   0   28G  0 part
└─360022480525429a9490838203d86beec    253:0    0   28G  0 mpath
  └─360022480525429a9490838203d86beec1 253:1    0   28G  0 part
sdc                                      8:32   0   10G  0 disk
└─sdc1                                   8:33   0   10G  0 part  /data1
sdd                                      8:48   0  100G  0 disk
└─360003ff44dc75adc9a0c97b937e4dabe    253:2    0  100G  0 mpath
  └─360003ff44dc75adc9a0c97b937e4dabe1 253:5    0  100G  0 part
sde                                      8:64   0  100G  0 disk
└─360003ff44dc75adc8924a08a83ca9802    253:3    0  100G  0 mpath
sdf                                      8:80   0  100G  0 disk
└─360003ff44dc75adc9c3ecef884b1381b    253:4    0  100G  0 mpath
sdg                                      8:96   0  100G  0 disk
└─360003ff44dc75adcb9492d273d6bdf5a    253:6    0  100G  0 mpath
sr0                                     11:0    1 1024M  0 rom

there is still 360003ff44dc75adc9a0c97b937e4dabe1

```


```bash
lsblk
iscsiadm -m session 
iscsiadm -m session -u
iscsiadm -m node -p 192.168.1.30 --op=delete
```

from Windows, remove the disks and recreate them:

```powershell
Get-IscsiServerTarget

Get-IscsiVirtualDisk -path J:\ivhdx0.vhdx
Remove-IscsiVirtualDiskTargetMapping -Path J:\ivhdx0.vhdx -TargetName w1i0
Remove-IscsiVirtualDisk -path J:\ivhdx0.vhdx

Get-IscsiVirtualDisk -path J:\ivhdx1.vhdx
Remove-IscsiVirtualDiskTargetMapping -Path J:\ivhdx1.vhdx -TargetName w1i0
Remove-IscsiVirtualDisk -path J:\ivhdx1.vhdx

Get-IscsiVirtualDisk -path J:\ivhdx2.vhdx
Remove-IscsiVirtualDiskTargetMapping -Path J:\ivhdx2.vhdx -TargetName w1i0
Remove-IscsiVirtualDisk -path J:\ivhdx2.vhdx

Get-IscsiVirtualDisk -path J:\ivhdx3.vhdx
Remove-IscsiVirtualDiskTargetMapping -Path J:\ivhdx3.vhdx -TargetName w1i0
Remove-IscsiVirtualDisk -path J:\ivhdx3.vhdx


dir J:\
del J:\ivhdx*.vhdx
dir J:\

New-IscsiVirtualDisk -Path J:\ivhdx0.vhdx -SizeBytes 107374182400 -UseFixed -DoNotClearData
Add-IscsiVirtualDiskTargetMapping -Path J:\ivhdx0.vhdx -TargetName w1i0 -Lun 0

New-IscsiVirtualDisk -Path J:\ivhdx1.vhdx -SizeBytes 107374182400 -UseFixed -DoNotClearData
Add-IscsiVirtualDiskTargetMapping -Path J:\ivhdx1.vhdx -TargetName w1i0 -Lun 1

New-IscsiVirtualDisk -Path J:\ivhdx2.vhdx -SizeBytes 107374182400 -UseFixed -DoNotClearData
Add-IscsiVirtualDiskTargetMapping -Path J:\ivhdx2.vhdx -TargetName w1i0 -Lun 2

New-IscsiVirtualDisk -Path J:\ivhdx3.vhdx -SizeBytes 107374182400 -UseFixed -DoNotClearData
Add-IscsiVirtualDiskTargetMapping -Path J:\ivhdx3.vhdx -TargetName w1i0 -Lun 3

(Get-IscsiServerTarget w1i0).LunMappings

Get-IscsiVirtualDisk -Path J:\ivhdx0.vhdx | format-table Path, SerialNumber, Status
Get-IscsiVirtualDisk -Path J:\ivhdx1.vhdx | format-table Path, SerialNumber, Status
Get-IscsiVirtualDisk -Path J:\ivhdx2.vhdx | format-table Path, SerialNumber, Status
Get-IscsiVirtualDisk -Path J:\ivhdx3.vhdx | format-table Path, SerialNumber, Status

```

refresh on all nodes

```bash
iscsiadm -m discovery -t sendtargets -p 192.168.1.30
iscsiadm -m node -L automatic
# this can be interrupted (CTRL-C) once the first login to `192.168.1.30` is successful.

# next lines are optional
multipath -l
lsblk
ll /dev/mapper
```

## Security Handshake

```
Creation of the IBM General Parallel File System (GPFS) cluster,
"db2cluster_20180410231202.d1", succeeded on host "d1".

Creation of the IBM General Parallel File System (GPFS) file system succeeded
at mount point "/db2sd_20180410231311".

ERROR: The security handshake failed between host, "d1", and, "d2". Ensure the
hosts are online, the host names are specified correctly on the systems, and
the networks are correctly set up on the hosts. Re-try DB2 installation. If the
problem persists, contact IBM support.

ERROR: The security handshake failed between host, "d1", and, "cf1". Ensure the
hosts are online, the host names are specified correctly on the systems, and
the networks are correctly set up on the hosts. Re-try DB2 installation. If the
problem persists, contact IBM support.

ERROR: The security handshake failed between host, "d1", and, "cf2". Ensure the
hosts are online, the host names are specified correctly on the systems, and
the networks are correctly set up on the hosts. Re-try DB2 installation. If the
problem persists, contact IBM support.
```

cf <https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/r0061630.html?pos=2>

on the 4 nodes, add open ports to the firewall rules

```
firewall-cmd --add-port=1191/tcp --permanent
firewall-cmd --add-port=12347/udp --permanent
firewall-cmd --add-port=12348/udp --permanent
firewall-cmd --add-port=657/udp --permanent
firewall-cmd --reload
```

seems not sufficient so disable firewall until we find a better solution

```
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
```

## There is already a file system

```
/opt/ibm/db2/V11.1/instance/db2icrt -cf cf1 -cfnet cf1 -cf cf2 -cfnet cf2 -m d1 -mnet d1 -m d2 -mnet d2 -instance_shared_dev /dev/sdd -tbdev /dev/sdg -u db2sdfe1 db2sdin1

(...)

ERROR: The instance shared device "/dev/sdd" was specified. However, the DB2 installer
has detected that there is already an existing user managed GPFS cluster on the
host. To use an existing user managed file system for the DB2 pureScale
instance setup, specify the directory instead of the device path. Specify the
directory using either the instance shared directory option, or the
INSTANCE_SHARED_DIR keyword. For details about user managed file system,
instance shared device path or instance shared directory, see the DB2
Informaiton Center.

ERROR: The "db2icrt" command failed. Ensure that errors reported in the log
file are fixed, then rerun the command.
```


```
[root@d1 V11.1]# /opt/ibm/db2/V11.1/bin/db2cluster -cfs -list -filesystem
FILE SYSTEM NAME                       MOUNT POINT
---------------------------------      -------------------------
db2fs1                                 /db2sd_20180411000011

[root@d1 V11.1]# /opt/ibm/db2/V11.1/bin/db2cluster -cfs -delete -filesystem db2fs1
The shared file system cluster has not been started. Start the cluster with 'db2cluster -cfs -start -all' and re-issue this command.
A diagnostic log has been saved to '/tmp/ibm.db2.cluster.Gixsus'.


```

## uninstall DB2 before reinstalling it

<https://www.ibm.com/support/knowledgecenter/en/SSEPGG_10.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0007435.html>

```bash
cd /opt/ibm/db2/V11.1/install/
./db2_deinstall -a
```

## drop the DB2 nodes and recreate them

```bash
az login
az account set -s "$subscription"

rg=gluster-iscsi

az vm list -g $rg
az vm delete -y -g $rg --name d1 &
az vm delete -y -g $rg --name d2 &
az vm delete -y -g $rg --name cf1 &
az vm delete -y -g $rg --name cf2 &
az vm list -g $rg
```

once all VM are removed 

```bash
db2vmimage='RedHat:RHEL:7.3:7.3.2017090723'
az vm create --resource-group $rg --name d1 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics d1-client d1-cluster d1-db2client --data-disk-sizes-gb 32 --no-wait
az vm create --resource-group $rg --name d2 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics d2-client d2-cluster d2-db2client --data-disk-sizes-gb 32 --no-wait
az vm create --resource-group $rg --name cf1 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics cf1-client cf1-cluster --data-disk-sizes-gb 32 --no-wait
az vm create --resource-group $rg --name cf2 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics cf2-client cf2-cluster --data-disk-sizes-gb 32 --no-wait

az vm list -g $rg

az vm get-instance-view -g $rg --name d1
az vm get-instance-view -g $rg --name d2
az vm get-instance-view -g $rg --name cf1
az vm get-instance-view -g $rg --name cf2
```

once all VM are up and running

```bash
scp rhel@$jumpbox:/home/rhel/.ssh/id_rsa.pub jumbox_id_rsa.pub
az vm user update -g $rg --name d1 --username rhel --ssh-key-value jumbox_id_rsa.pub --no-wait
az vm user update -g $rg --name d2 --username rhel --ssh-key-value jumbox_id_rsa.pub --no-wait
az vm user update -g $rg --name cf1 --username rhel --ssh-key-value jumbox_id_rsa.pub --no-wait
az vm user update -g $rg --name cf2 --username rhel --ssh-key-value jumbox_id_rsa.pub --no-wait

ssh rhel@$jumpbox
vi /home/rhel/.ssh/known_hosts
```

remove old nodes corresponding to 192.168.1.20, 192.168.1.21, 192.168.1.40, 192.168.1.41.

execute steps in [db2_setup](db2_setup.md)

remove orphan disks:

```bash
for v in d1 d2 cf1 cf2
do
  disks=`az disk list -g $rg | grep "${v}_disk2" | awk '{print $1}'`
  for d in $disks
  do
    orphan=`az disk show -g $rg --name $d --output json | grep managedBy | grep " null," | wc -l`
    if [ "$orphan" == "1" ]
    then
      echo $d is an orphan
      az disk delete -y -g $rg --name $d
    fi
  done
done
```

## ABRT has detected 1 problem(s)

```
[rhel@cf1 ~]$ sudo su
ABRT has detected 1 problem(s). For more info run: abrt-cli list
[root@cf1 rhel]# abrt-cli list
id bc3b270d1b311fb692bf95e5a24ca7292c4567d4
reason:         NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [systemd-udevd:220]
time:           Thu 12 Apr 2018 02:35:01 PM UTC
cmdline:        BOOT_IMAGE=/vmlinuz-3.10.0-514.28.1.el7.x86_64 root=UUID=3c11fba3-32c7-4d0c-b614-aad5630504eb ro console=tty1 console=ttyS0 earlyprintk=ttyS0 rootdelay=300
package:        kernel
uid:            0 (root)
count:          1
Directory:      /var/spool/abrt/oops-2018-04-12-14:35:01-568-0
Run 'abrt-cli report /var/spool/abrt/oops-2018-04-12-14:35:01-568-0' for creating a case in Red Hat Customer Portal

The Autoreporting feature is disabled. Please consider enabling it by issuing
'abrt-auto-reporting enabled' as a user with root privileges
```

## db2icrt doesn't allow the use of symlinks as device names

<http://www-01.ibm.com/support/docview.wss?uid=swg21969333>

> The raw device name must be used in the db2icrt command, because DB2 requires real device nodes with device numbers in the format /dev/dm-n
> 
> Note that RedHat documentation implies that raw device names may be problematic when used because the are dynamic. However DB2 design is such that this doesn't pose problem to DB2, the reason is GPFS does device discovery based on nsd header and not on the dm-X name. GPFS keeps track of the devices in nsdmap and does nsddiscovery when gets started based on nsd header written on the disk so dm-X being different from orignal is fine.


## A few commands to check the state of the cluster, or remove uninstalled components

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

## need to remove GPFS

<https://www.ibm.com/support/knowledgecenter/SSFKCN_4.1.0/com.ibm.cluster.gpfs.v4r1.gpfs300.doc/bl1ins_uninstall.htm>

```
The instance shared device "/dev/dm-2" was specified. However, the DB2
installer has detected that there is already an existing user managed GPFS
cluster on the host. To use an existing user managed file system for the DB2
pureScale instance setup, specify the directory instead of the device path.
Specify the directory using either the instance shared directory option, or the
INSTANCE_SHARED_DIR keyword. For details about user managed file system,
instance shared device path or instance shared directory, see the DB2
Informaiton Center.
```

```bash
/usr/lpp/mmfs/bin/mmshutdown -a
yum list gpfs*
rpm -e gpfs.docs.noarch
rpm -e gpfs.ext.x86_64
rpm -e gpfs.gpl.noarch
rpm -e gpfs.gskit.x86_64
rpm -e gpfs.msg.en_US.noarch
rpm -e gpfs.base.x86_64 
yum list gpfs*
```

optionally:

```
rm -rf /var/mmfs
rm -rf /usr/lpp/mmfs
rm -f /var/adm/ras/mm*
rm -rf /tmp/mmfs
```

## volume create: db2data: failed: /bricks/db2data/db2data is already part of a volume

```
[root@g0 rhel]# gluster volume create db2data replica 3 g0b:/bricks/db2data/db2data g1b:/bricks/db2data/db2data g2b:/bricks/db2data/db2data
volume create: db2data: failed: /bricks/db2data/db2data is already part of a volume
[root@g0 rhel]# ls -als /bricks/db2data/db2data/
total 0
0 drwxr-xr-x. 3 root root 24 May 21 09:48 .
0 drwxr-xr-x. 3 root root 21 May 21 06:30 ..
0 drw-------. 3 root root 21 May 21 09:48 .glusterfs
[root@g0 rhel]# rm -rf /bricks/db2data/db2data/.glusterfs/
[root@g0 rhel]# ls -als /bricks/db2data/db2data/
total 0
0 drwxr-xr-x. 2 root root  6 May 21 09:49 .
0 drwxr-xr-x. 3 root root 21 May 21 06:30 ..
[root@g0 rhel]# gluster volume create db2data replica 3 g0b:/bricks/db2data/db2data g1b:/bricks/db2data/db2data g2b:/bricks/db2data/db2data
volume create: db2data: failed: /bricks/db2data/db2data is already part of a volume
```

<https://stackoverflow.com/questions/39446546/glusterfs-volume-creation-failed-brick-is-already-part-of-volume>

```
[root@g0 rhel]# gluster volume create db2data replica 3 g0b:/bricks/db2data/db2data g1b:/bricks/db2data/db2data g2b:/bricks/db2data/db2data force
volume create: db2data: success: please start the volume to access data
[root@g0 rhel]# gluster volume start db2data
volume start: db2data: success
```

## The template deployment ___ is not valid according to the validation procedure

```
The template deployment 'deployment_180521b' is not valid according to the validation procedure. The tracking id is '6f6a11d7-9298-49e8-b6ce-00f18e973fe6'. See inner errors for details. Please see https://aka.ms/arm-deploy for usage details.
```

Please check the quota in your subscription. You may run out of cores to deploy the solution.
Make somn space and retry.