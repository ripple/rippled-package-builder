#!/bin/bash

gpg --import private.key
gpg --export -a "Ripple Release Engineering" > RPM-GPG-KEY-ripple-release
rpm --import RPM-GPG-KEY-ripple-release
echo "%_gpg_name root" >> ~/.rpmmacros
echo "%_gpg /usr/bin/gpg" >> ~/.rpmmacros
echo "%_gpg_path /root/.gnupg" >> ~/.rpmmacros

cd rippled
git fetch origin

if [ -n "$COMMIT_HASH" ]; then
  git checkout $COMMIT_HASH
else
  echo "Missing COMMIT_HASH"
  exit 1
fi

# Verify git commit signature
COMMIT_SIGNER=`git verify-commit HEAD 2>&1 >/dev/null | grep 'Good signature from' | grep -oP '\"\K[^"]+'`
if [ -z "$COMMIT_SIGNER" ]; then
  ERROR="git commit signature verification failed"
else
  RIPPLED_VERSION=$(egrep -i -o "\b(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9a-z\-]+(\.[0-9a-z\-]+)*)?(\+[0-9a-z\-]+(\.[0-9a-z\-]+)*)?\b" src/ripple/protocol/impl/BuildInfo.cpp)

  # Convert dashes to underscores in rippled version for rpm compatibility
  RIPPLED_RPM_VERSION=`echo "$RIPPLED_VERSION" | tr - _`
  export RIPPLED_RPM_VERSION

  # Build and sign the rpm
  cd ..

  tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/

  rpmbuild -ba $1
  rpmsign --key-id="Ripple Release Engineering" --addsign ~/rpmbuild/RPMS/x86_64/*.rpm ~/rpmbuild/SRPMS/*.rpm

  # Upload a tar of the rpm and source rpm to s3
  tar -zvcf $RIPPLED_VERSION.tar.gz -C ~/rpmbuild/RPMS/x86_64/ . -C ~/rpmbuild/SRPMS/ .
  aws s3 cp $RIPPLED_VERSION.tar.gz s3://$S3_BUCKET --region $S3_REGION

  MD5SUM=`rpm -Kv ~/rpmbuild/RPMS/x86_64/*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
fi

if [ -n "$ERROR" ]; then
  echo $ERROR
  aws sqs send-message --queue-url $SQS_QUEUE_FAILED --message-body "{\"stage\":\"rpm-builder\", \"error\":\"$ERROR\", \"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
  exit 1
fi

aws sqs send-message --queue-url $SQS_QUEUE_UPLOADED --message-body "{\"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"s3_bucket\":\"$S3_BUCKET\", \"s3_key\":\"$RIPPLED_VERSION.tar.gz\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
