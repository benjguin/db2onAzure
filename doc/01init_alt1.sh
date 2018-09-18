#!/bin/bash


# in the init-private, I set $lisbits and $db2bits urls to reuse existing ones
. ./01init-private.sh

# runs the default init
. ./01init.sh

# overrides some values to match an alternate environment 
subscription="Microsoft Azure Internal Consumption"
localGitFolderpath=/mnt/c/proj/
tempLocalFolder=/mnt/c/tmp/db2