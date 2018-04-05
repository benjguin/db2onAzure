#!/bin/bas

#clean up gluster VMs
az vm delete -y -n g1 --no-wait
az vm delete -y -n g2 --no-wait
az vm delete -y -n g3 --no-wait

#clean up nics
az network nic delete -n g1-backend
az network nic delete -n g1-client
az network nic delete -n g2-backend
az network nic delete -n g2-client
az network nic delete -n g3-backend
az network nic delete -n g3-client

#clean up disks