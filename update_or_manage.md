# update or manage

Here are commands that can be used to update or manage the infrastructure

## drop the DB2 nodes and recreate them

```bash
az login
az account set -s "$subscription"

rg=gluster-iscsi

az vm list -g $rg
az vm delete -y -g $rg --name d1 --nowait
az vm delete -y -g $rg --name d2 --nowait
az vm delete -y -g $rg --name cf1 --nowait
az vm delete -y -g $rg --name cf2 --nowait
az vm list -g $rg
```

once all VM are removed 

```bash
az vm create --resource-group $rg --name d1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d1-client d1-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group $rg --name d2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d2-client d2-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group $rg --name cf1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf1-client cf1-cluster cf1-db2client --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group $rg --name cf2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf2-client cf2-cluster cf2-db2client --data-disk-sizes-gb 10 --no-wait

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

