#!/bin/bash

rg=gluster-iscsi

#clean up VMs
az vm delete -g $rg -n g1 -y --no-wait
az vm delete -g $rg -n g2 -y --no-wait
az vm delete -g $rg -n g3 -y --no-wait

#clean up nics
az network nic delete -g $rg -n g1-backend 
az network nic delete -g $rg -n g1-client
az network nic delete -g $rg -n g2-backend
az network nic delete -g $rg -n g2-client
az network nic delete -g $rg -n g3-backend
az network nic delete -g $rg -n g3-client

for disk in `az disk list -g $rg | grep g1|awk '{print $1}'`; do az disk delete -y -g $rg -n $disk; done
for disk in `az disk list -g $rg | grep g2|awk '{print $1}'`; do az disk delete -y -g $rg -n $disk; done
for disk in `az disk list -g $rg | grep g3|awk '{print $1}'`; do az disk delete -y -g $rg -n $disk; done