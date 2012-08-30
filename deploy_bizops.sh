#!/bin/bash

BOSH_TARGET=http://172.20.134.84:25555
WORKSPACE=`pwd`
RELEASE=bizops-release
MANIFEST_PATH=$WORKSPACE/manifests/dev101-composite.yml
RELEASE_NAME=pivotal

source $WORKSPACE/scripts/common.sh

# we don't reset the repo here. because we mannually put topology-ci.yml and database-ci.yml in it
sync_up_repo  $RELEASE
update_submodules $RELEASE

# sync up the src/billing-service repo
cd $WORKSPACE/$RELEASE/src/billing-services
git checkout master
git pull

bosh target $BOSH_TARGET
bosh login admin admin

mkdir $WORKSPACE/logs

create_upload_deploy_release $WORKSPACE/$RELEASE $MANIFEST_PATH $RELEASE_NAME

# will enable this after it's stable
# echo "yes" | bosh cleanup

exit 0
