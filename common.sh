#!/bin/bash
source ~/.bash_login

set -x

sync_up_repo() {
  cd ${WORKSPACE}/$1
  if [ $2 = 'reset'  ] ; then
    git reset --hard
  fi
  git pull --rebase
}

update_submodules() {
  echo "Updating submodules for $1 repo"
  cd $WORKSPACE/$1
  git submodule sync
  git submodule update --init --recursive
}

# This method is just to check that every bosh command we ran is successful and if yes only then
# we move ahead else we exit out.
check_success() {
  actual_output="`tail -n 1 $1`"
  # $2 has the expected output that we try to check
  if [ `expr match "$actual_output" ".*$2.*"` != "0" ]; then
    echo "Successful!";
  else
    echo "The last command was not successful, please debug and try again!"
    exit 1
  fi;
}

create_upload_deploy_release() {
  cd $1

  # create release
  echo $3 | bosh create release --force | tee $WORKSPACE/logs/$3_create_release.log
  check_success $WORKSPACE/logs/$3_create_release.log "Release manifest"

  # set the bosh target
  bosh target $BOSH_TARGET | tee $WORKSPACE/logs/$3_set_target.log
  check_success $WORKSPACE/logs/$3_set_target.log "Target.*set to.*$BOSH_TARGET"

  # upload release
  echo "yes" | bosh upload release | tee $WORKSPACE/logs/$3_upload_release.log
  check_success $WORKSPACE/logs/$3_upload_release.log ".*uploaded.*"

  # Here we get the latest version number and the release name created and uploaded from
  # release_name/config/dev.yml and write it to the new manifest named release_name.yml.
  VERSION=`grep 'latest_release_filename.*' $1/config/dev.yml | sed -e "s/latest_release_filename.*$3-\(.*\)\.yml/\1/g"`
  sed -e "3,/name:.*/s/name:.*/name: $3/" -e "0,/version:.*/s/version:.*/version: $VERSION/" $2 > $WORKSPACE/$3.yml

  cd $1
  # set the deployment to the new manifest we created
  bosh deployment $2 | tee $WORKSPACE/logs/$3_set_deployment.log
  check_success $WORKSPACE/logs/$3_set_deployment.log "Deployment.*set to.*$2"

  # now we are all set to deploy
  #echo "yes" | bosh deploy | tee $WORKSPACE/logs/$3_deploy.log
  bosh --non-interactive deploy | tee $WORKSPACE/logs/$3_deploy.log
  check_success $WORKSPACE/logs/$3_deploy.log "Deployed.*to.*"
}
