#!/bin/bash

function error {
  echo $1
  exit 1
}

yum groupinstall -y "Development Tools"
curl --silent --location https://rpm.nodesource.com/setup | bash -
yum install -y yum-utils nodejs

# Check rpm's md5sum
mkdir rpms
tar -zxvf in/$RPM_FILE_NAME -C rpms
rpm_md5sum="$(rpm -Kv rpms/*.x86_64.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+')"

if [ "$MD5SUM" != "$rpm_md5sum" ]; then
  echo -e "\nChecksum failed!"
  echo -e "\nExiting....."
  exit 1
else
  echo -e "\nChecksum passed!"
fi

rpm -Uvh https://mirrors.ripple.com/ripple-repo-el7.rpm
yum install -y --enablerepo=ripple-stable protobuf-devel protobuf-static ripple-boost ripple-boost-devel ripple-boost-static ripple-openssl-devel ripple-openssl-static openssl-devel ripple-boost-coroutine
rpm -Uvh rpms/rippled-*.x86_64.rpm
rc=$?; if [[ $rc != 0 ]]; then
  error "error installing rippled-$RIPPLED_VERSION rpm from $YUM_REPO"
fi

rpm -i rpms/rippled-*.src.rpm
tar -zxf ~/rpmbuild/SOURCES/rippled.tar.gz -C ./
cd rippled
npm install
mkdir build
ln -s /opt/ripple/bin/rippled build/rippled

/opt/ripple/bin/rippled --unittest
rc=$?; if [[ $rc != 0 ]]; then
  error "rippled --unittest failed"
fi

npm test
rc=$?; if [[ $rc != 0 ]]; then
  error "npm test failed"
fi