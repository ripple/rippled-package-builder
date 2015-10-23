#!/bin/bash

function error {
  echo $1
  aws sqs send-message --queue-url $SQS_QUEUE_FAILED --message-body "{\"stage\":\"rpm-builder\", \"error\":\"$1\", \"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
  exit 1
}

gpg --import gpg/private.key
rc=$?; if [[ $rc != 0 ]]; then
  error "error importing private.key"
fi

gpg --export -a "Ripple Release Engineering" > RPM-GPG-KEY-ripple-release
rc=$?; if [[ $rc != 0 ]]; then
  error "error exporting \"Ripple Release Engineering\" public key"
fi

rpm --import RPM-GPG-KEY-ripple-release
echo "%_gpg_name root" >> ~/.rpmmacros
echo "%_gpg /usr/bin/gpg" >> ~/.rpmmacros
echo "%_gpg_path /root/.gnupg" >> ~/.rpmmacros

cd rippled
git fetch origin

git checkout $COMMIT_HASH
rc=$?; if [[ $rc != 0 ]]; then
  error "error checking out $COMMIT_HASH"
fi

# Verify git commit signature
COMMIT_SIGNER=`git verify-commit HEAD 2>&1 >/dev/null | grep 'Good signature from' | grep -oP '\"\K[^"]+'`
if [ -z "$COMMIT_SIGNER" ]; then
  error "git commit signature verification failed"
fi
RIPPLED_VERSION=$(egrep -i -o "\b(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9a-z\-]+(\.[0-9a-z\-]+)*)?(\+[0-9a-z\-]+(\.[0-9a-z\-]+)*)?\b" src/ripple/protocol/impl/BuildInfo.cpp)

# Convert dashes to underscores in rippled version for rpm compatibility
RIPPLED_RPM_VERSION=`echo "$RIPPLED_VERSION" | tr - _`
export RIPPLED_RPM_VERSION

# Build and sign the rpm
cd ..

tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/

rpmbuild -ba $1
rc=$?; if [[ $rc != 0 ]]; then
  error "error building rpm"
fi

rpmsign --key-id="Ripple Release Engineering" --addsign ~/rpmbuild/RPMS/x86_64/*.rpm ~/rpmbuild/SRPMS/*.rpm
rc=$?; if [[ $rc != 0 ]]; then
  error "error signing rpm"
fi

# Upload a tar of the rpm and source rpm to s3
tar -zvcf $RIPPLED_VERSION.tar.gz -C ~/rpmbuild/RPMS/x86_64/ . -C ~/rpmbuild/SRPMS/ .
aws s3 cp $RIPPLED_VERSION.tar.gz s3://$S3_BUCKET --region $S3_REGION
rc=$?; if [[ $rc != 0 ]]; then
  error "error uploading $RIPPLED_VERSION.tar.gz to s3://$S3_BUCKET"
fi

MD5SUM=`rpm -Kv ~/rpmbuild/RPMS/x86_64/*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`

aws sqs send-message --queue-url $SQS_QUEUE_UPLOADED --message-body "{\"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"s3_bucket\":\"$S3_BUCKET\", \"s3_key\":\"$RIPPLED_VERSION.tar.gz\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
rc=$?; if [[ $rc != 0 ]]; then
  error "error sending message to $SQS_QUEUE_UPLOADED"
fi
