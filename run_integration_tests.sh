#!/bin/bash
WORKSPACE=`pwd`
SPEC_REPORT=$WORKSPACE/spec_reports
source $WORKSPACE/scripts/common.sh

sync_up_repo billing-services

cd $WORKSPACE/billing-services/common
bundle install

cd $WORKSPACE/billing-services/spec

# clean the old spec reports
find .. -mindepth 2 \( -name spec_reports \) -exec rm -rf {} \;
rm -f $SPEC_REPORT

rake ci:setup:rspec spec:ci_integration

# cp out the new spec reports
mkdir -p $WORKSPACE/spec_reports
find .. -mindepth 2 \( -name spec_reports \) -exec cp -vrf {} $SPEC_REPORT \;

exit 0
