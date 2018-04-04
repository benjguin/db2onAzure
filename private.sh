#!/bin/bash

# this is a sample file with a few variables setup.
# please change with your own values
# you may have to execute this on different nodes

# the following must be set before `create_azure_sources.sh`
subscription="my azure subscription"
pubKeyPath=~/.ssh/id_rsa.pub

# the following must be set before `db2_setup.sh`
jumpbox="jump.example.com"
db2bits="https://myaccount.blob.core.windows.net/setup/v11.1_linuxx64_server_t.tar.gz?mysharedaccesssignature"
