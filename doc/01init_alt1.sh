#!/bin/bash

<<<<<<< Updated upstream

# in the init-private, I set $lisbits and $db2bits urls to reuse existing ones
current_dir=`dirname $0`
. $current_dir/01init-private.sh

# pre-set the dateid to affect the unique name generation
dateid="180918ster"

# runs the default init
. $current_dir/01init.sh

# overrides some values to match an alternate environment 
subscription="Microsoft Azure Internal Consumption"
localGitFolderpath=/mnt/c/proj/
tempLocalFolder=/mnt/c/tmp/db2