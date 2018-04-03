#!/bin/bash

# please execute private.sh before this script in order to setup variables

az login
az account set -s "$subscription"

echo "Creating Resource group..."
az group create -n gluster-iscsi
echo "Creating VNET and two subnets..."
az network vnet create \
 --resource-group gluster-iscsi \
 --name gluster \
 --address-prefix 192.168.0.0/16 \
 --subnet-name client \
 --subnet-prefix 192.168.1.0/24
az network vnet subnet create \
 --resource-group gluster-iscsi \
 --vnet-name gluster \
 --name backend \
 --address-prefix 192.168.2.0/24
echo "Creating NSG..."
az network nsg create \
 --resource-group gluster-iscsi \
 --name gluster-nsg
az network nsg rule create --nsg-name gluster-nsg -g gluster-iscsi --name allow-ssh --description "SSHDB2" --protocol tcp --priority 101 --destination-port-range "22"
echo "Creating 2 Nics per VM..."
az network nic create --resource-group gluster-iscsi --name g1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.10
az network nic create --resource-group gluster-iscsi --name g1-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.10
az network nic create --resource-group gluster-iscsi --name g2-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.11
az network nic create --resource-group gluster-iscsi --name g2-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.11
az network nic create --resource-group gluster-iscsi --name g3-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.12
az network nic create --resource-group gluster-iscsi --name g3-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.12
echo "Create VM's..."
az vm create --resource-group gluster-iscsi --name g1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics g1-client g1-backend --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name g2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics g2-client g2-backend --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name g3 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics g3-client g3-backend --data-disk-sizes-gb 10 --no-wait
#az vm create --resource-group gluster-iscsi --name g1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics jumpbox --no-wait
echo "Create Jumpbox.."
az network public-ip create -g gluster-iscsi -n jumpbox-pubip --allocation-method Static --dns-name jumpboxgluster
az network nic create --resource-group gluster-iscsi --name jumpbox --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.5 --public-ip-address jumpbox-pubip
az vm create --resource-group gluster-iscsi --name jumpbox --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS2_v2 --admin-username rhel --nics jumpbox --no-wait

echo "adding db2cluster subnet..."
az network vnet subnet create \
 --resource-group gluster-iscsi \
 --vnet-name gluster \
 --name db2cluster \
 --address-prefix 192.168.3.0/24
echo "Creating 2 Nics per VM..."
az network nic create --resource-group gluster-iscsi --name cf1-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.10
az network nic create --resource-group gluster-iscsi --name cf2-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.11
az network nic create --resource-group gluster-iscsi --name d1-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.20
az network nic create --resource-group gluster-iscsi --name d1-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.20
az network nic create --resource-group gluster-iscsi --name d2-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.21
az network nic create --resource-group gluster-iscsi --name d2-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.21
az network nic create --resource-group gluster-iscsi --name d3-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.22
az network nic create --resource-group gluster-iscsi --name d3-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.22
az network nic create --resource-group gluster-iscsi --name d4-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.23
az network nic create --resource-group gluster-iscsi --name d4-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.23
echo "Create VM's..."
az vm create --resource-group gluster-iscsi --name d1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d1-client d1-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name d2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d2-client d2-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name d3 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d3-client d3-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name d4 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d4-client d4-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name cf1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf1-client cf1-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name cf2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf2-client cf2-cluster --data-disk-sizes-gb 10 --no-wait
