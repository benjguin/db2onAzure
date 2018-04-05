#!/bin/bash

# please execute private.sh before this script in order to setup variables

az login
az account set -s "$subscription"

rg=gluster-iscsi

echo "Creating Resource group..."
az group create -n $rg

echo "Creating VNET and three subnets..."
az network vnet create \
 --resource-group $rg \
 --name gluster \
 --address-prefix 192.168.0.0/16 \
 --subnet-name client \
 --subnet-prefix 192.168.1.0/24
az network vnet subnet create \
 --resource-group $rg \
 --vnet-name gluster \
 --name backend \
 --address-prefix 192.168.2.0/24
 az network vnet subnet create \
 --resource-group $rg \
 --vnet-name gluster \
 --name db2cluster \
 --address-prefix 192.168.3.0/24

echo "Creating NSG..."
az network nsg create \
 --resource-group $rg \
 --name gluster-nsg
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-ssh --description "SSHDB2" --protocol tcp --priority 101 --destination-port-range "22"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-iscsi --description "iSCSI" --protocol tcp --priority 201 --destination-port-range "3260"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-gluster-bricks --description "Gluster-bricks" --protocol tcp --priority 202 --destination-port-range "49152-49160"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-gluster-daemon --description "Gluster-daemon" --protocol "*" --priority 203 --destination-port-range "24007-24008"


echo "Creating 2 Nics per Gluster VM..."
az network nic create --resource-group $rg --name g1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.10 --accelerated-networking true
az network nic create --resource-group $rg --name g1-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.10 --accelerated-networking true
az network nic create --resource-group $rg --name g2-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.11 --accelerated-networking true
az network nic create --resource-group $rg --name g2-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.11 --accelerated-networking true
az network nic create --resource-group $rg --name g3-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.12 --accelerated-networking true
az network nic create --resource-group $rg --name g3-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.12 --accelerated-networking true

echo "Create Gluster VM's..."
az vm create --resource-group $rg --name g1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics g1-client g1-backend --data-disk-sizes-gb 10 --no-wait --custom-data start_network.sh
az vm create --resource-group $rg --name g2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics g2-client g2-backend --data-disk-sizes-gb 10 --no-wait --custom-data start_network.sh
az vm create --resource-group $rg --name g3 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2 --admin-username rhel --nics g3-client g3-backend --data-disk-sizes-gb 10 --no-wait --custom-data start_network.sh

echo "Create Jumpbox.."
az network public-ip create -g $rg -n jumpbox-pubip --allocation-method Static --dns-name jumpboxgluster
az network nic create --resource-group $rg --name jumpbox --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.5 --public-ip-address jumpbox-pubip
az vm create --resource-group $rg --name jumpbox --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS2_v2 --admin-username rhel --nics jumpbox --no-wait


echo "Creating Nics per DB2 caching VM..."
az network nic create --resource-group $rg --name cf1-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.10
az network nic create --resource-group $rg --name cf2-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.11

echo "Creating Nics per DB2 server VM..."

az network nic create --resource-group $rg --name d1-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.20
az network nic create --resource-group $rg --name d1-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.20
az network nic create --resource-group $rg --name d2-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.21
az network nic create --resource-group $rg --name d2-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.21
az network nic create --resource-group $rg --name d3-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.22
az network nic create --resource-group $rg --name d3-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.22
az network nic create --resource-group $rg --name d4-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.23
az network nic create --resource-group $rg --name d4-client  --vnet-name gluster --subnet client     --network-security-group gluster-nsg --private-ip-address 192.168.1.23

echo "Create DB2 VM's..."
az vm create --resource-group $rg --name d1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d1-client d1-cluster --no-wait
az vm create --resource-group $rg --name d2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d2-client d2-cluster --no-wait
az vm create --resource-group $rg --name d4 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d4-client d4-cluster --no-wait
az vm create --resource-group $rg --name cf1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf1-client cf1-cluster --no-wait
az vm create --resource-group $rg --name cf2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf2-client cf2-cluster --no-wait
