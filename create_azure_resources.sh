#!/bin/bash

# please execute private.sh before this script in order to setup variables

az login
az account set -s "$subscription"

echo "Creating Resource group..."
az group create -n gluster-iscsi --location westeurope
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
# TODO: test the following line
az vm user update -g gluster-iscsi --name jumpbox --username rhel --ssh-key-value $pubKeyPath

echo "adding db2cluster subnet..."
az network vnet subnet create \
 --resource-group gluster-iscsi \
 --vnet-name gluster \
 --name db2cluster \
 --address-prefix 192.168.3.0/24
echo "adding db2client subnet..."
az network vnet subnet create \
 --resource-group gluster-iscsi \
 --vnet-name gluster \
 --name db2client \
 --address-prefix 192.168.4.0/24
echo "Creating 2 Nics per VM..."
az network nic create --resource-group gluster-iscsi --name cf1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.40
az network nic create --resource-group gluster-iscsi --name cf2-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.41
az network nic create --resource-group gluster-iscsi --name cf1-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.40
az network nic create --resource-group gluster-iscsi --name cf2-cluster --vnet-name gluster --subnet db2cluster --network-security-group gluster-nsg --private-ip-address 192.168.3.41
az network nic create --resource-group gluster-iscsi --name cf1-db2client --vnet-name gluster --subnet db2client --network-security-group gluster-nsg --private-ip-address 192.168.4.40
az network nic create --resource-group gluster-iscsi --name cf2-db2client --vnet-name gluster --subnet db2client --network-security-group gluster-nsg --private-ip-address 192.168.4.41
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
#az vm create --resource-group gluster-iscsi --name d3 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d3-client d3-cluster --data-disk-sizes-gb 10 --no-wait
#az vm create --resource-group gluster-iscsi --name d4 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics d4-client d4-cluster --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name cf1 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf1-client cf1-cluster cf1-db2client --data-disk-sizes-gb 10 --no-wait
az vm create --resource-group gluster-iscsi --name cf2 --image RedHat:RHEL:7-RAW-CI:latest --size Standard_DS3_v2_Promo --admin-username rhel --nics cf2-client cf2-cluster cf2-db2client --data-disk-sizes-gb 10 --no-wait

# TODO: generate keypair on the jumpboxn get the public key and update the public keys on all VMs 
# so that the jumpbox can connect to all VMs
# TODO test
ssh rhel@$jumpbox -t -t << EOF
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
EOF

scp rhel@$jumpbox:/home/rhel/.ssh/id_rsa.pub jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name g1 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name g2 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name g3 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name d1 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name d2 --username rhel --ssh-key-value jumbox_id_rsa.pub
#az vm user update -g gluster-iscsi --name d3 --username rhel --ssh-key-value jumbox_id_rsa.pub
#az vm user update -g gluster-iscsi --name d4 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name cf1 --username rhel --ssh-key-value jumbox_id_rsa.pub
az vm user update -g gluster-iscsi --name cf2 --username rhel --ssh-key-value jumbox_id_rsa.pub


# Add Windows iSCSI targets (non clustered) to test also with this option
#az network nsg rule create --nsg-name gluster-nsg -g gluster-iscsi --name allow-winRM --description "WinRM" --protocol tcp --priority 102 --destination-port-range "5986"
az network nsg rule create --nsg-name gluster-nsg -g gluster-iscsi --name allow-RDP --description "WinRDP" --protocol tcp --priority 103 --destination-port-range "3389"
az network public-ip create -g gluster-iscsi -n w1-pubip --allocation-method Dynamic --dns-name db2w1
az network nic create --resource-group gluster-iscsi --name w1-client --vnet-name gluster --subnet client --network-security-group gluster-nsg --private-ip-address 192.168.1.30 --public-ip-address w1-pubip
az vm create --resource-group gluster-iscsi --name w1 \
    --image MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest \
    --size Standard_DS3_v2_Promo --nics w1-client \
    --data-disk-sizes-gb 10 10 \
    --admin-username adwin --admin-password "$adwinPassword" \
    --no-wait


