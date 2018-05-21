#!/bin/bash

nbDb2MemberVms=$1
nbDb2CfVms=$2

# write a response file

cat > /root/db2server.rsp <<EOF
*-----------------------------------------------------
* Generated response file 
* see fromd0_root.sh script
*-----------------------------------------------------
*  Product Installation
LIC_AGREEMENT       = ACCEPT
PROD       = DB2_SERVER_EDITION
FILE       = /data1/db2
INSTALL_TYPE       = CUSTOM
COMP       = TSAMP
COMP       = INFORMIX_DATA_SOURCE_SUPPORT
COMP       = IINR_APPLICATIONS_WRAPPER
COMP       = SQL_PROCEDURES
COMP       = ORACLE_DATA_SOURCE_SUPPORT
COMP       = ODBC_DATA_SOURCE_SUPPORT
COMP       = IINR_SCIENTIFIC_WRAPPER
COMP       = INSTANCE_SETUP_SUPPORT
COMP       = TERADATA_DATA_SOURCE_SUPPORT
COMP       = LDAP_EXPLOITATION
COMP       = APPLICATION_DEVELOPMENT_TOOLS
COMP       = FED_DATA_SOURCE_SUPPORT
COMP       = CONNECT_SUPPORT
COMP       = GUARDIUM_INST_MNGR_CLIENT
COMP       = DB2_UPDATE_SERVICE
COMP       = JDBC_DATA_SOURCE_SUPPORT
COMP       = IINR_STRUCTURED_FILES_WRAPPER
COMP       = BASE_DB2_ENGINE
COMP       = REPL_CLIENT
COMP       = TEXT_SEARCH
COMP       = JDK
COMP       = DB2_SAMPLE_DATABASE
COMP       = DB2_DATA_SOURCE_SUPPORT
COMP       = JAVA_SUPPORT
COMP       = SYBASE_DATA_SOURCE_SUPPORT
COMP       = GPFS
COMP       = SQL_SERVER_DATA_SOURCE_SUPPORT
COMP       = FIRST_STEPS
COMP       = PURESCALE
COMP       = SPATIAL_EXTENDER_SERVER_SUPPORT
COMP       = BASE_CLIENT
COMP       = ACS
COMP       = COMMUNICATION_SUPPORT_TCPIP
COMP       = SPATIAL_EXTENDER_CLIENT_SUPPORT
* ----------------------------------------------
*  Instance properties
* ----------------------------------------------
INSTANCE       = inst1
EOF

for (( i=0; i<$nbDb2MemberVms; i++ ))
do
j=$(($i+1))
cat >> /root/db2server.rsp <<EOF
inst1.MEMBER       = host$j
EOF
done

for (( i=0; j<$nbDb2CfVms; i++ ))
do
j=$(($nbDb2MemberVms+1+$i))
cat >> /root/db2server.rsp <<EOF
inst1.PREFERRED_PRIMARY_CF       = host$j
EOF
done

cat >> /root/db2server.rsp <<EOF
inst1.TYPE       = dsf
*  Instance-owning user
inst1.NAME       = db2sdin1
inst1.UID       = 1001
inst1.GROUP_NAME       = db2iadm1
inst1.HOME_DIRECTORY       = /home/db2sdin1
inst1.START_DURING_INSTALL       = YES
*  Fenced user
inst1.FENCED_USERNAME       = db2sdfe1
inst1.FENCED_UID       = 1002
inst1.FENCED_GROUP_NAME       = db2fadm1
inst1.FENCED_HOME_DIRECTORY       = /home/db2sdfe1
*-----------------------------------------------
*  Installed Languages
*-----------------------------------------------
LANG       = EN
*-----------------------------------------------
*  Host Information
*-----------------------------------------------
EOF

for (( i=0; i<$nbDb2MemberVms; i++ ))
do
j=$(($i+1))
cat >> /root/db2server.rsp <<EOF
HOST       = host$j
host1.HOSTNAME       = d$i-eth1
host1.CLUSTER_INTERCONNECT_NETNAME       = d${i}-eth2
EOF
done

for (( i=0; j<$nbDb2CfVms; i++ ))
do
j=$(($nbDb2MemberVms+1+$i))
cat >> /root/db2server.rsp <<EOF
HOST       = host$j
host1.HOSTNAME       = cf$i-eth1
host1.CLUSTER_INTERCONNECT_NETNAME       = cf${i}-eth2
EOF
done

# see <http://www-01.ibm.com/support/docview.wss?uid=swg21969333>

devdb2data1=`ls -ls /dev/mapper | grep db2data1 | awk '{sub(/\.\./,"/dev"); print $12}'`
devdb2log1=`ls -ls /dev/mapper | grep db2log1 | awk '{sub(/\.\./,"/dev"); print $12}'`
devdb2shared=`ls -ls /dev/mapper | grep db2shared | awk '{sub(/\.\./,"/dev"); print $12}'`
devdb2tieb=`ls -ls /dev/mapper | grep db2tieb | awk '{sub(/\.\./,"/dev"); print $12}'`

cat >> /root/db2server.rsp <<EOF


* ----------------------------------------------
*  Shared file system settings
* ----------------------------------------------
INSTANCE_SHARED_DEVICE_PATH       = $devdb2shared
INSTANCE_SHARED_MOUNT       = /db2sd_1804a
DATA_SHARED_MOUNT       = /db2fs/datafs1
LOG_SHARED_MOUNT       = /db2fs/logfs1
DATA_SHARED_DEVICE_PATH       = $devdb2data1
LOG_SHARED_DEVICE_PATH       = $devdb2log1


* ----------------------------------------------
*  Tiebreaker settings
* ----------------------------------------------
DB2_CLUSTER_SERVICES_TIEBREAKER_DEVICE_PATH       = $devdb2tieb
EOF

tentativenum=001
/data2/db2bits/server_t/db2setup -r /root/db2server.rsp -l /tmp/db2setup_${tentativenum}.log -t /tmp/db2setup_${tentativenum}.trc
