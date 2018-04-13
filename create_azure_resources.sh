#!/bin/bash

# please execute private.sh before this script in order to setup variables

az login
az account set -s "$subscription"

rg=gluster-iscsi

echo "Creating Resource group..."
az group create -n $rg --location westeurope

echo "Creating VNET and subnets..."
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
 az network vnet subnet create \
 --resource-group $rg \
 --vnet-name gluster \
 --name db2client \
 --address-prefix 192.168.4.0/24

echo "Creating NSG..."
az network nsg create \
 --resource-group $rg \
 --name gluster-nsg
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-ssh --description "SSHDB2" --protocol tcp --priority 101 --destination-port-range "22"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-iscsi --description "iSCSI" --protocol tcp --priority 201 --destination-port-range "3260"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-gluster-bricks --description "Gluster-bricks" --protocol tcp --priority 202 --destination-port-range "49152-49160"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-gluster-daemon --description "Gluster-daemon" --protocol "*" --priority 203 --destination-port-range "24007-24010"
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-rpcbind --description "RPCbind" --protocol "*" --priority 204 --destination-port-range "111"


echo "Creating 2 Nics per Gluster VM..."
az network nic create --resource-group $rg --name g1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.10 --accelerated-networking true
az network nic create --resource-group $rg --name g1-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.10 --accelerated-networking true
az network nic create --resource-group $rg --name g2-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.11 --accelerated-networking true
az network nic create --resource-group $rg --name g2-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.11 --accelerated-networking true
az network nic create --resource-group $rg --name g3-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.12 --accelerated-networking true
az network nic create --resource-group $rg --name g3-backend --vnet-name gluster --subnet backend --network-security-group gluster-nsg --private-ip-address 192.168.2.12 --accelerated-networking true

echo "Create Gluster VM's..."
az vm create --resource-group $rg --name g1 --image RedHat:RHEL:7-RAW:7.4.2018010506 --size Standard_DS4_v2 --admin-username rhel --nics g1-client g1-backend --data-disk-sizes-gb 1000 1000 --no-wait #--custom-data start_network.sh
az vm create --resource-group $rg --name g2 --image RedHat:RHEL:7-RAW:7.4.2018010506 --size Standard_DS4_v2 --admin-username rhel --nics g2-client g2-backend --data-disk-sizes-gb 1000 1000 --no-wait #--custom-data start_network.sh
az vm create --resource-group $rg --name g3 --image RedHat:RHEL:7-RAW:7.4.2018010506 --size Standard_DS4_v2 --admin-username rhel --nics g3-client g3-backend --data-disk-sizes-gb 1000 1000 --no-wait #--custom-data start_network.sh

echo "Create Jumpbox.."
az network public-ip create -g $rg -n jumpbox-pubip --allocation-method Static --dns-name jumpboxgluster
az network nic create --resource-group $rg --name jumpbox --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.5 --public-ip-address jumpbox-pubip
az vm create --resource-group $rg --name jumpbox --image RedHat:RHEL:7-RAW:7.4.2018010506 --size Standard_DS2_v2 --admin-username rhel --nics jumpbox --no-wait
az vm user update -g $rg --name jumpbox --username rhel --ssh-key-value $pubKeyPath

echo "Creating Nics per DB2 caching VM..."
az network nic create --resource-group $rg --name cf1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.40
az network nic create --resource-group $rg --name cf2-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.41
az network nic create --resource-group $rg --name cf1-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.40
az network nic create --resource-group $rg --name cf2-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.41
az network nic create --resource-group $rg --name cf1-db2client --vnet-name gluster --subnet db2client --network-security-group gluster-nsg --private-ip-address 192.168.4.40
az network nic create --resource-group $rg --name cf2-db2client --vnet-name gluster --subnet db2client --network-security-group gluster-nsg --private-ip-address 192.168.4.41

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
db2vmimage='RedHat:RHEL:7.3:7.3.2017090723'
az vm create --resource-group $rg --name d1 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics d1-client d1-cluster --data-disk-sizes-gb 32 --no-wait
az vm create --resource-group $rg --name d2 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics d2-client d2-cluster --data-disk-sizes-gb 32 --no-wait
az vm create --resource-group $rg --name cf1 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics cf1-client cf1-cluster cf1-db2client --data-disk-sizes-gb 32 --no-wait
az vm create --resource-group $rg --name cf2 --image "$db2vmimage" --size Standard_DS3_v2_Promo --admin-username rhel --nics cf2-client cf2-cluster cf2-db2client --data-disk-sizes-gb 32 --no-wait

# TODO: generate keypair on the jumpbox, get the public key and update the public keys on all VMs 
# so that the jumpbox can connect to all VMs
# TODO test
ssh rhel@$jumpbox -t -t << EOF
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
EOF

scp rhel@$jumpbox:/home/rhel/.ssh/id_rsa.pub jumbox_id_rsa.pub
az vm user update -g $rg --name g1 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g $rg --name g2 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g $rg --name g3 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g $rg --name d1 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g $rg --name d2 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g $rg --name cf1 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g $rg --name cf2 --username rhel --ssh-key-value jumbox_id_rsa.pub

# Add a Witness server
az network nic create --resource-group $rg --name witn1-db2cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.60
az network nic create --resource-group $rg --name witn1-db2client --vnet-name gluster --subnet db2client --network-security-group gluster-nsg --private-ip-address 192.168.4.60
az vm create --resource-group $rg --name witn1 --image OpenLogic:CentOS:7.3:latest --size Standard_B1s --admin-username rhel --nics witn1-db2cluster witn1-db2client --no-wait

# Add a Windows client
az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-RDP --description "WinRDP" --protocol tcp --priority 103 --destination-port-range "3389"
az network public-ip create -g $rg -n cli1-pubip --allocation-method Dynamic --dns-name db2cli1
az network nic create --resource-group $rg --name cli1-db2client --vnet-name gluster --subnet db2client --network-security-group gluster-nsg --private-ip-address 192.168.4.50 --public-ip-address cli1-pubip
az vm create --resource-group $rg --name cli1 \
    --image MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest \
    --size Standard_DS3_v2_Promo --nics cli1-db2client \
    --admin-username adwin --admin-password "$adwinPassword" \
    --no-wait

# Add Windows iSCSI targets (non clustered) to test also with this option
#az network nsg rule create --nsg-name gluster-nsg -g $rg --name allow-winRM --description "WinRM" --protocol tcp --priority 102 --destination-port-range "5986"
az network public-ip create -g $rg -n w1-pubip --allocation-method Dynamic --dns-name db2w1
az network nic create --resource-group $rg --name w1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.30 --public-ip-address w1-pubip
az vm create --resource-group $rg --name w1 \
    --image MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest \
    --size Standard_DS3_v2_Promo --nics w1-client \
    --data-disk-sizes-gb 512 \
    --admin-username adwin --admin-password "$adwinPassword" \
    --no-wait
