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

Once you've checked that the logs look good, connect to the deployed nodes and checks according to article KB017 in the [Knowledge Base](KB.md)



For troubleshooting, please check the [KB](KB.md).

