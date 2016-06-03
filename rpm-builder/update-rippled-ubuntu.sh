#!/bin/bash

RIPPLE_REPO=${RIPPLE_REPO-stable}

# Update ripple.repo file
rpm -Uvh --replacepkgs https://mirrors.ripple.com/ripple-repo-el7.rpm

yum --disablerepo=* --enablerepo=ripple-$RIPPLE_REPO clean expire-cache
installed_version=`dpkg-parsechangelog --show-field Version -l/usr/share/doc/rippled/changelog.Debian.gz`
repo_version=`repoquery --enablerepo=ripple-nightly --releasever=el7 --qf="%{version}-%{release}" rippled | sed -r 's/_//;s/.{11}$//'`

if [ "$installed_version" != "$repo_version" ]; then
  yumdownloader --enablerepo=ripple-$RIPPLE_REPO --releasever=el7 rippled
  rpm -K rippled*.rpm
  service rippled stop
  alien -i --scripts rippled*.rpm
  service rippled start
  rm rippled*.rpm
fi
