#!/bin/bash

rg=$1

az vm delete -y -g $rg --name d0
az vm delete -y -g $rg --name d1
az vm delete -y -g $rg --name cf0
az vm delete -y -g $rg --name cf1

az network nic delete -g $rg --name cf0_db2be &
az network nic delete -g $rg --name cf0_gfsfe &
az network nic delete -g $rg --name cf0_main &
az network nic delete -g $rg --name cf1_db2be &
az network nic delete -g $rg --name cf1_gfsfe &  
az network nic delete -g $rg --name cf1_main &  
az network nic delete -g $rg --name d0_db2be &  
az network nic delete -g $rg --name d0_db2fe &  
az network nic delete -g $rg --name d0_gfsfe &  
az network nic delete -g $rg --name d0_main &  
az network nic delete -g $rg --name d1_db2be &  
az network nic delete -g $rg --name d1_db2fe &  
az network nic delete -g $rg --name d1_gfsfe &  
az network nic delete -g $rg --name d1_main &  

az disk delete --yes -g $rg --name cf0_dataDisk_lun0 &
az disk delete --yes -g $rg --name cf0_osDisk &
az disk delete --yes -g $rg --name cf1_dataDisk_lun0 &
az disk delete --yes -g $rg --name cf1_osDisk &
az disk delete --yes -g $rg --name d0_dataDisk_lun0 &
az disk delete --yes -g $rg --name d0_osDisk &
az disk delete --yes -g $rg --name d1_dataDisk_lun0 &
az disk delete --yes -g $rg --name d1_osDisk &
