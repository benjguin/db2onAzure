#!/bin/bash

# this is called only when accelerated network is needed on DB2 nodes

lisbits=$1

# remove unused versions of the kernel to avoid this message: your running kernel 3.10.0-514.el7.x86_64 is not your latest installed kernel, aborting installation
rpm -q kernel
uname -r
yum remove -y kernel-3.10.0-514.28.1.el7.x86_64
rpm -q kernel

mkdir /tmp/lis
cd /tmp/lis
echo "lisbits=$lisbits"
curl -o lis-rpms-4.2.4-2.tar.gz "$lisbits"
tar xvf lis-rpms-4.2.4-2.tar.gz
cd LISISO
bash ./install.sh
