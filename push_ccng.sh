#!/bin/bash

TARGET=http://api.cf101.dev.las01.vcsops.com
WORKSPACE=`pwd`
RELEASE=cloud_controller_ng

source $WORKSPACE/scripts/common.sh

sync_up_repo  $RELEASE 'reset'

# cp the pre-defined cloud_controller.yml
cp $WORKSPACE/manifests/cloud_controller.yml $WORKSPACE/$RELEASE/config/cloud_controller.yml

vmc target $TARGET
vmc login --email admin@vmware.com --password password

cd $WORKSPACE/$RELEASE

vmc delete ccng -n
vmc push -n

exit $?
