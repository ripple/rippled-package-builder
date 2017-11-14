#!/bin/bash
set -e

function error {
  echo $1
  exit 1
}

apt-get update
apt-get install -y yum-utils alien

mkdir rpms
tar -zxvf in/$RPM_FILE_NAME -C rpms

alien -i --scripts rpms/rippled*.rpm

/opt/ripple/bin/rippled --unittest
rc=$?; if [[ $rc != 0 ]]; then
  error "rippled --unittest failed"
fi

/opt/ripple/bin/validator-keys --unittest
rc=$?; if [[ $rc != 0 ]]; then
  error "validator-keys --unittest failed"
fi
