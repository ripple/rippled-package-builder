#!/bin/bash
yum install -y --enablerepo=ripple-stable rippled

yumdownloader --source --enablerepo=ripple-stable rippled
rpm -i rippled-*.src.rpm
tar -zxf ~/rpmbuild/SOURCES/rippled.tar.gz -C ./
cd rippled
npm install
mkdir build
ln -s /opt/ripple/bin/rippled build/rippled

npm test

rc=$?; if [[ $rc != 0 ]]; then
  echo "npm test failed"
  exit $rc
fi

/opt/ripple/bin/rippled --unittest

rc=$?; if [[ $rc != 0 ]]; then
  echo "rippled --unittest failed"
  exit $rc
fi

echo "tests passed"

# make request to rippled-build-bot