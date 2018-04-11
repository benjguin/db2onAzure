# db2onAzure

DB2 pureScale setup on Azure

## Resources

- <https://www.ibm.com/analytics/us/en/db2/trials/>
- [Installing a Db2 pureScale environment (Linux)](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/t0061541.html)

## main steps

The main steps, in order, are the following: 

- `private.ps1` and `private.sh` initialize a few variables
- `create_azure_resources.sh` creates Azure resources
- iSCSI targets can be installed as
    - Windows single node fro dev purposes
        - `winsetup.ps1`
    - GlusterFS
        - `install_config_gluster.sh`
        - `gluster_setup.sh`
        - `iscsi_client_setup.sh`
- `db2_setup.md` configures and installs DB2 nodes. It leverages the following files
    - `start_network.sh`
    - `db2server.rsp`
- `KB.md` has a number of know issues and how they could be fixe or diagnosed
