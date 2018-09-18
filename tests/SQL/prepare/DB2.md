# prepare DB2 for the SQL tests

```bash
ssh rhel@$jumpbox
ssh d0
sudo su - db2sdin1 # use db2user instead for single VMs

db2 get instance
db2 list database directory
db2 create database test1
db2 list database directory
db2 activate database test1
db2 connect to test1
db2 get db cfg | grep LOG
db2 update db cfg using LOGFILSIZ 1000000
db2 update db cfg using LOGPRIMARY 127
db2 update db cfg using LOGSECOND 127
db2 connect reset
db2 restart database test1
```

resources:
- [Resolving "The transaction log for the database is full" error](http://www-01.ibm.com/support/docview.wss?uid=swg21472442)