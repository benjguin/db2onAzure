# Knowledge Base

Known issues and fixes or diagnostics path

## need to have a witness node

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
# define the witness. cf https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0061581.html
cat <<EOF > /var/ct/cfg/netmon.cf
!REQD eth0 192.168.1.30
!REQD eth1 192.168.3.60
EOF

nbnics=`ls -A /sys/class/net/ | wc -l`
if [ $nbnics == 4 ]
then
cat <<EOF >> /var/ct/cfg/netmon.cf
!REQD eth2 192.168.4.60
EOF
fi
```


## GPL compilation

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
export SHARKCLONEROOT=/usr/lpp/mmfs/src
make
```

<https://stackoverflow.com/questions/45866521/ibm-gpfs-4-2-1-compile-error>

```
vi /usr/lpp/mmfs/src/gpl-linux/kdump.c 
```

add the following line:

```c
unsigned long page_offset_base;
```

```
make
```

## GPFS is in use

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

form Windows, remove the disks and recreate them:

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
```

refresh on all nodes

```bash
lsblk
iscsiadm -m session 
iscsiadm -m session -u
iscsiadm -m node -p 192.168.1.30 --op=delete
iscsiadm -m discovery -t sendtargets -p 192.168.1.30
iscsiadm -m node -L automatic
multipath -l
lsblk
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