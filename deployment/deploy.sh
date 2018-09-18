#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Parameters

usage() { 
    echo "Expected arguments are: "
    echo "- subscription (-s): Azure subscription name"
    echo "- resourceGroupName (-g): Azure resource group name"
    echo "- location (-l): Azure region where the resources will be created"
    echo "- deploymentName (-n): Azure region where the resources will be created"
    echo "- pubKeyPath (-k): path to the public key to be used for jumpbox access"
    echo "- adwinPassword (-p): password for the 'adwin' user on Windows boxes"
    echo "- db2bits (-d): location where the 'v11.1_linuxx64_server_t.tar.gz' file can be downloaded from. You should manually download it from https://www.ibm.com/analytics/us/en/db2/trials/ first, then copy it somewhere like on Azure storage."
    echo "- gitrawurl (-u): folder where this repo is, with a trailing /. E.g.: https://raw.githubusercontent.com/benjguin/db2onAzure/master/"
    echo "- jumpboxPublicName (-j): jumpbox public DNS name. The full DNS name will be <jumpboxPublicName>.<location>.cloudapp.azure.com."
	echo "- temp local folder (-t) for ssh keys and other files, with a trailing /."
	echo "- acceleratedNetworkingOnGlusterfs (-a). Should the Gluster FS NICs have accelerated networking enabled? Possible values: true or false."
	echo "- acceleratedNetworkingOnDB2 (-c). Should the DB2 NICs have accelerated networking enabled? Possible values: true or false."
	echo "- acceleratedNetworkingOnOthers (-e). Should the other NICs have accelerated networking enabled? Possible values: true or false."
	echo "- lisbits (-b). location where the 'lis-rpms-4.2.x.tar.gz' file can be downloaded from. You can first manually download it from https://www.microsoft.com/en-us/download/details.aspx?id=55106"
	echo "- nbDb2MemberVms (-y) - nb of DB2 member VMs - default is 2"
	echo "- nbDb2CfVms (-z) - nb of DB2 caching facilities (CF) VMs - default and recommended value is 2 (the deployment was not tested with less and may not be supported with 3 or more as there is only 1 primary CF role and 1 secondary CF role)"
    echo ""
    echo "Usage: $0 -s <subscription> -g <resourceGroupName> -l <location> -n <deploymentName> -k <pubKeyPath> -p <adwinPassword> -d <db2bits> -u <gitrawurl> -j <jumpboxPublicName> -t <tempLocalFolder> -ag <acceleratedNetworkingOnGlusterfs> -ad <acceleratedNetworkingOnDB2> -ao <acceleratedNetworkingOnOthers> -adb <lisbits> -y nbDb2MemberVms -z nbDb2CfVms " 1>&2
    exit 1
}

declare subscription=""
declare rg=""
declare location=""
declare pubKeyPath=""
declare adwinPassword=""
declare db2bits=""
declare gitrawurl=""
declare jumpboxPublicName=""
declare tempLocalFolder=""
declare acceleratedNetworkingOnGlusterfs=""
declare acceleratedNetworkingOnDB2=""
declare acceleratedNetworkingOnOthers=""
declare lisbits=""
declare nbDb2MemberVms=2
declare nbDb2CfVms=2

# Initialize parameters specified from command line
while getopts ":a:b:c:d:e:g:j:k:l:n:p:s:t:u:y:z:" arg; do
	case "${arg}" in
		a)
			acceleratedNetworkingOnGlusterfs=${OPTARG}
			;;
		c)
			acceleratedNetworkingOnDB2=${OPTARG}
			;;
		e)
			acceleratedNetworkingOnOthers=${OPTARG}
			;;
		b)
			lisbits=${OPTARG}
			;;
		d)
			db2bits=${OPTARG}
			;;
		g)
			rg=${OPTARG}
			;;
		j)
			jumpboxPublicName=${OPTARG}
			;;
		k)
			pubKeyPath=${OPTARG}
			;;
		l)
			location=${OPTARG}
			;;
		n)
			deploymentName=${OPTARG}
			;;
		p)
			adwinPassword=${OPTARG}
			;;
		s)
			subscription=${OPTARG}
			;;
		t)
			tempLocalFolder=${OPTARG}
			;;
		u)
			gitrawurl=${OPTARG}
			;;
		y)
			nbDb2MemberVms=${OPTARG}
			;;
		z)
			nbDb2CfVms=${OPTARG}
			;;

		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$subscription" ]]; then
	echo "Your subscription name can be looked up with the CLI using: az account list"
	echo "Enter your subscription name:"
	read subscription
	[[ "${subscription:?}" ]]
fi

if [[ -z "$rg" ]]; then
	echo "This script will look for an existing resource group, otherwise a new one will be created "
	echo "You can create new resource groups with the CLI using: az group create "
	echo "Enter a resource group name"
	read rg
	[[ "${rg:?}" ]]
fi

if [[ -z "$location" ]]; then
	echo "If creating a *new* resource group, you need to set a location "
	echo "You can lookup locations with the CLI using: az account list-locations "
	echo "default value: westeurope"
	
	echo "Enter resource group location:"
	read location
    if [[ -z "$location" ]]; then
        location="westeurope"
    fi
fi

if [[ -z "$deploymentName" ]]; then
	echo "Enter a name for this deployment:"
	read deploymentName
    [[ "${deploymentName:?}" ]]
fi

if [[ -z "$pubKeyPath" ]]; then
	echo "Enter a name for the public key path (default value: ~/.ssh/id_rsa.pub):"
	read pubKeyPath
    if [[ -z "$pubKeyPath" ]]; then
        pubKeyPath=~/.ssh/id_rsa.pub
    fi
fi

if [[ -z "$adwinPassword" ]]; then
	echo "Enter a password for the 'adwin' user on Windows nodes:"
	read adwinPassword
    [[ "${adwinPassword:?}" ]]
fi

if [[ -z "$db2bits" ]]; then
	echo "Enter a URL where the 'v11.1_linuxx64_server_t.tar.gz' file can be downloaded from :"
	read db2bits
    [[ "${db2bits:?}" ]]
fi

if [[ -z "$gitrawurl" ]]; then
	echo "Enter a folder where this repo is, with a trailing /:"
	read gitrawurl
    [[ "${gitrawurl:?}" ]]
fi

if [[ -z "$jumpboxPublicName" ]]; then
	echo "Enter a jumpbox public name (a default random value would be provided otherwise):"
	read jumpboxPublicName
fi

if [[ "$(dig +short ${jumpboxPublicName}.${location}.cloudapp.azure.com)" ]]; then
	echo "${jumpboxPublicName}.${location}.cloudapp.azure.com is an existing dns record. Choose a different jumpbox name"
	exit 1
fi

if [[ -z "$tempLocalFolder" ]]; then
	echo "$tempLocalFolder not found, defaulting to current folder"
	tempLocalFolder="${DIR}/"
fi

if [[ -z "$acceleratedNetworkingOnGlusterfs" ]]; then
	echo "Assuming you do NOT want accelerated networking on Gluster FS nodes"
	acceleratedNetworkingOnGlusterfs=false
fi

if [[ -z "$acceleratedNetworkingOnDB2" ]]; then
	echo "Assuming you do NOT want accelerated networking on DB2 nodes"
	acceleratedNetworkingOnDB2=false
fi

if [[ -z "$acceleratedNetworkingOnOthers" ]]; then
	echo "Assuming you do NOT want accelerated networking on other nodes"
	acceleratedNetworkingOnOthers=false
fi

if [[ -z "$lisbits" ]]; then
	if [ "$acceleratedNetworkingOnDB2" == "true" ]; then
		echo "Enter a URL where the 'lis-rpms-4.2.4-2.tar.gz' file can be downloaded from :"
		read lisbits
		[[ "${lisbits:?}" ]]
	fi
fi

#templateFile Path - template file to be used
templateFilePath="${DIR}/template.json"

if [ ! -f "$templateFilePath" ]; then
	echo "$templateFilePath not found"
	exit 1
fi

#parameter file path
parametersFilePath="${DIR}/parameters.json"

if [ ! -f "$parametersFilePath" ]; then
	echo "$parametersFilePath not found"
	exit 1
fi

if [ ! -f "$pubKeyPath" ]; then
	echo "$pubKeyPath not found"
	exit 1
fi

pubKeyValue=`cat $pubKeyPath`

#login to azure using your credentials
az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

#set the default subscription id
az account set -s "$subscription"

#Check for existing RG
searchresult=`az group show -g $rg | wc -l`

if [ "$searchresult" == "0" ]; then
	echo "Resource group with name ${rg} could not be found. Creating new resource group.."
	(
		set -x
		az group create --name ${rg} --location ${location} 1> /dev/null
	)
	else
	echo "Using existing resource group..."
fi

if [ ! -f "${tempLocalFolder}/rhelid_rsa" ]; then
	echo 'generating ssh keys'
	# for production, Azure key vaults or othe means should be leveraged
	ssh-keygen -t rsa -f ${tempLocalFolder}rhelid_rsa -q -N ""
	ssh-keygen -t rsa -f ${tempLocalFolder}rootid_rsa -q -N ""
else
	echo "reusing ssh key files available in folder ${tempLocalFolder}"
fi

rhelPrivKeyValue=`base64 ${tempLocalFolder}rhelid_rsa`
rhelPubKeyValue=`cat ${tempLocalFolder}rhelid_rsa.pub`
rootPrivKeyValue=`base64 ${tempLocalFolder}rootid_rsa`
rootPubKeyValue=`cat ${tempLocalFolder}rootid_rsa.pub`

#Start deployment
echo "Starting deployment..."

az group deployment create --name "$deploymentName" --resource-group "$rg" --template-file "$templateFilePath" \
	--parameters "@${parametersFilePath}" \
	--parameters userPubKeyValue="$pubKeyValue" \
	--parameters rhelPrivKeyValue="$rhelPrivKeyValue" rhelPubKeyValue="$rhelPubKeyValue" \
	--parameters rootPrivKeyValue="$rootPrivKeyValue" rootPubKeyValue="$rootPubKeyValue" \
	--parameters adwinPassword="$adwinPassword" \
	--parameters db2bits="$db2bits" gitrawurl="$gitrawurl" jumpboxPublicName="$jumpboxPublicName" \
	--parameters acceleratedNetworkingOnGlusterfs="$acceleratedNetworkingOnGlusterfs" \
	--parameters acceleratedNetworkingOnDB2="$acceleratedNetworkingOnDB2" \
	--parameters acceleratedNetworkingOnOthers="$acceleratedNetworkingOnOthers" \
	--parameters nbDb2MemberVms="$nbDb2MemberVms" nbDb2CfVms="$nbDb2CfVms" \
	--parameters lisbits="$lisbits"

if [ $?  == 0 ];
then
	echo "Template has been successfully deployed"
else
	echo "Template was NOT successfully deployed"
	exit 1
fi

#rm -f ${DIR}/rhelid_rsa
#rm -f ${DIR}/rhelid_rsa.pub
#rm -f ${DIR}/rootid_rsa
#rm -f ${DIR}/rootid_rsa.pub

jumpbox="${jumpboxPublicName}.${location}.cloudapp.azure.com"
nbDb2MemberVms=`az group deployment show -g $rg -n "$deploymentName" --query properties.outputs.nbDb2MemberVms.value --output json`
nbDb2CfVms=`az group deployment show -g $rg -n "$deploymentName" --query properties.outputs.nbDb2CfVms.value --output json`

scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/wait4reboots_src.sh rhel@$jumpbox:/tmp/
scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/fromjumpbox.sh rhel@$jumpbox:/tmp/
scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/fromd0_root.sh rhel@$jumpbox:/tmp/
scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/fromd0getwwids_root.sh rhel@$jumpbox:/tmp/
scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/fromg0_root.sh rhel@$jumpbox:/tmp/

if [ `echo "$acceleratedNetworkingOnDB2" | awk '{print tolower($0)}'` == "true" ]
then
	scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/fromdcfan_root.sh rhel@$jumpbox:/tmp/
	scp -o StrictHostKeyChecking=no ${DIR}/postARMscripts/fromjumpbox-prepare-an.sh rhel@$jumpbox:/tmp/
	ssh -o StrictHostKeyChecking=no rhel@$jumpbox "bash -v /tmp/fromjumpbox-prepare-an.sh $nbDb2MemberVms $nbDb2CfVms \"$lisbits\" &> >(tee -a /tmp/postARM-prepare-an.log)"

	db2serverNames=()
	for (( i=0; i<$nbDb2MemberVms; i++ ))
	do
		db2serverNames+=(d$i)
	done
	for (( i=0; i<$nbDb2CfVms; i++ ))
	do
		db2serverNames+=(cf$i)
	done

	# deallocate in parallel
	for db2vm in "${db2serverNames[@]}"
	do
		az vm deallocate -g $rg --name ${db2vm} &
	done

	for db2vm in "${db2serverNames[@]}"
	do
		echo "adding accelerated network to ${db2vm}. First wait for deallocation to finish."
		stay="true"
		tries=0
		while [ "$stay" == "true" ]
		do
			echo "dbg-180608a [${db2vm}]"
			x1=`az vm get-instance-view -g $rg --name ${db2vm} --output json | grep PowerState`
			echo "${db2vm} power state: $x1"
			x=`echo $x1 | grep deallocated | wc -l`
			echo "dbg-180608b [${db2vm}] [${x1}] [${x}]"
			if [ "$x" == "1" ]
			then
				stay="false"
			else
				if [ $tries -gt 10 ]
				then
					echo "Servers did not deallocate correctly"
					exit 1
				fi
				echo "waiting for 30 seconds ..."
				sleep 30s
				((tries=tries+1))
			fi
		done
		echo "${db2vm} is deallocated"

		az network nic list -g $rg | grep ${db2vm}_
		echo "dbg-180608c [${db2vm}]"
		hasdb2fe=`az network nic list -g $rg | grep ${db2vm}_ | grep _db2fe | wc -l`
		echo "dbg-180608d [${db2vm}] [${hasdb2fe}]"

		az network nic update -g $rg --name ${db2vm}_main   --accelerated-networking true
		echo "dbg-180608e [${db2vm}]"
		az network nic update -g $rg --name ${db2vm}_db2be  --accelerated-networking true
		echo "dbg-180608f [${db2vm}]"
		az network nic update -g $rg --name ${db2vm}_gfsfe --accelerated-networking true
		echo "dbg-180608g [${db2vm}]"
		if [ "$hasdb2fe" == "1" ]
		then 
			echo "dbg-180608h [${db2vm}] [${hasdb2fe}]"
			az network nic update -g $rg --name ${db2vm}_db2fe --accelerated-networking true
			echo "dbg-180608i [${db2vm}] [${hasdb2fe}]"
		fi
		echo "dbg-180608j [${db2vm}] [${hasdb2fe}]"

		az network nic list -g $rg | grep ${db2vm}_
		echo "dbg-180608k [${db2vm}] [${hasdb2fe}]"
		az vm start -g $rg --name ${db2vm} &
		echo "dbg-180608l [${db2vm}] [${hasdb2fe}]"
	done
	echo "dbg-180608m"
fi
echo "dbg-180608n"

ssh -o StrictHostKeyChecking=no rhel@$jumpbox "bash -v /tmp/fromjumpbox.sh $nbDb2MemberVms $nbDb2CfVms $acceleratedNetworkingOnDB2 &> >(tee -a /tmp/postARM.log)"

az network nic list -g $rg
