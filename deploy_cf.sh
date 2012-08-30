#!/bin/bash

BOSH_TARGET=http://172.20.134.84:25555
WORKSPACE=`pwd`
RELEASE=cf-release
MANIFEST_PATH=$WORKSPACE/manifests/dev101-composite.yml
RELEASE_NAME=appcloud

source $WORKSPACE/scripts/common.sh

sync_up_repo  $RELEASE 'reset'
update_submodules $RELEASE

bosh target $BOSH_TARGET
bosh login admin admin

mkdir $WORKSPACE/logs

create_upload_deploy_release $RELEASE $MANIFEST_PATH $RELEASE_NAME

exit 0
