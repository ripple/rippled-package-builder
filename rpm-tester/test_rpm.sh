#!/bin/bash

# Check rpm's md5sum
yumdownloader --enablerepo=$YUM_REPO rippled
REPO_MD5SUM=`rpm -Kv *.x86_64.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
if [ "$REPO_MD5SUM" != "$MD5SUM" ]; then
  ERROR="md5sum mismatch ($REPO_MD5SUM)"
else
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
    ERROR="rippled --unittest failed"
  else
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ripple/openssl/lib:/opt/ripple/boost/lib npm test

    rc=$?; if [[ $rc != 0 ]]; then
      ERROR="npm test failed"
    fi
  fi
fi

if [ -n "$ERROR" ]; then
  echo $ERROR
  aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-failed --message-body "{\"stage\":\"rpm-tester\", \"error\":\"$ERROR\", \"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $AWS_REGION
  exit 1
fi

aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-tested --message-body "{\"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region us-west-2
