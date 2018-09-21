# install db2cli1 (Windows)

As part of the setup, we deployed a windows client (wcli0).
The windows client is accessible from the jumbox.
to connect to the RDP session, we first need to open a ssh tunnel :

## Connect to wcli0 thru an ssh tunnel

From [doc/use.md](../../../doc/use.md) :  
first, open an ssh tunnel that forwards port 3389 on your machine like so :
```bash
ssh -L 127.0.0.1:3390:192.168.0.40:3389 rhel@$jumpbox
```

then connect to the windows client trough with RDP through `127.0.0.1:3390`

On that windows client :

- Download a trial version of IBM data Studio from <https://www.ibm.com/developerworks/downloads/im/data/index.html/>
- Copy the zip file to D:\ (temporary local storage)
- Extract
- Run launchpad.exe and follow the instructions