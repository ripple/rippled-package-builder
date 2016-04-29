#!/bin/bash

RIPPLE_REPO=${RIPPLE_REPO-stable}

# Update ripple.repo file
rpm -Uvh --replacepkgs https://mirrors.ripple.com/ripple-repo-el7.rpm

yum --disablerepo=* --enablerepo=ripple-$RIPPLE_REPO clean expire-cache
yum check-update --enablerepo=ripple-$RIPPLE_REPO rippled

if [ $? -ne 0 ]; then
  yum update -y --enablerepo=ripple-$RIPPLE_REPO rippled
  systemctl daemon-reload
  /usr/sbin/service rippled restart
fi
