# db2onAzure

DB2 pureScale setup on Azure

## Resources

- <https://www.ibm.com/analytics/us/en/db2/trials/>
- [Installing a Db2 pureScale environment (Linux)](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0061541.html)

## main files and folders

- `deployment/deploy.sh` is the main script to deploy everything
- `deployment/otherScripts/` folder contains that may be useful for some tasks 
- `KB.md` has a number of know issues and how they could be fixe or diagnosed

## Topology

The ARM templates deploy the following:

Subnet name | IP address space | Comments
------------|------------------|-----------------------------------------------------------------
main        | 192.168.0.0/24   | Management. All primary NIcs should be on this subnet.
gfsfe       | 192.168.1.0/24   | Gluster FS Front end. This is where iSCSI connections happen.
gfsbe       | 192.168.2.0/24   | Gluster FS Back End (Gluster internal cluster network)
db2be       | 192.168.3.0/24   | DB2 pureScale Back End (DB2 internal cluster network)
db2fe       | 192.168.4.0/24   | DB2 pureScale Front End

The Vms have the following name prefixes and IP addresses

VM type | VM name | IP Address
--------|----------------|--------------------
Jumpbox | jumpbox | 192.168.0.5
Gluster FS | g{vm_number} | 192.168.{subnet}.1{vm_number}
DB2 member | d{vm_number} | 192.168.{subnet}.2{vm_number}
DB2 CF | cf{vm_number} | 192.168.{subnet}.3{vm_number}
Windows Client | wcli0 | 192.168.{subnet}.4{vm_number}
Witness | witn0 | 192.168.{subnet}.6{vm_number}

The [documentation](doc/README.md) provides a step by step procedure to use the ARM templates and scripts. 