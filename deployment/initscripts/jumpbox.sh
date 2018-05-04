#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
${DIR}/start_network.sh

ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
