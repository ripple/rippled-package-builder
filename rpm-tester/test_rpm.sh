#!/bin/bash
yum install -y --enablerepo=$YUM_REPO rippled

yumdownloader --source --enablerepo=$YUM_REPO rippled
rpm -i rippled-*.src.rpm
tar -zxf ~/rpmbuild/SOURCES/rippled.tar.gz -C ./
cd rippled
npm install
mkdir build
ln -s /opt/ripple/bin/rippled build/rippled

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ripple/openssl/lib:/opt/ripple/boost/lib /opt/ripple/bin/rippled --unittest

rc=$?; if [[ $rc != 0 ]]; then
  echo "rippled --unittest failed"
  exit $rc
fi

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ripple/openssl/lib:/opt/ripple/boost/lib npm test

rc=$?; if [[ $rc != 0 ]]; then
  echo "npm test failed"
  exit $rc
fi

echo "tests passed"

aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-tested --message-body '{"results":"passed"}' --region us-west-2
