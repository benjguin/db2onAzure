# Knowledge Base

Known issues and fixes or diagnostics path

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

Per <https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.upgrade.doc/doc/t0070169.html>, to compile manually: 

```bash
cd /usr/lpp/mmfs/src
export SHARKCLONEROOT=/usr/lpp/mmfs/src
make
```

