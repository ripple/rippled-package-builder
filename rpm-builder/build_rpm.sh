#!/bin/bash
git clone https://github.com/ripple/rippled.git

cd rippled

if [ -n "$COMMIT_HASH" ]; then
  git checkout $COMMIT_HASH
else
  echo "Missing COMMIT_HASH"
  exit 1
fi

# TODO Verify git commit signature


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
aws s3 cp $RIPPLED_VERSION.tar.gz s3://$S3_BUCKET

MD5SUM=`rpm -Kv ~/rpmbuild/RPMS/x86_64/*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-uploaded-test --message-body "{\"yum_repo\":\"ripple-stable\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"s3_bucket\":\"$S3_BUCKET\", \"s3_key\":\"$RIPPLED_VERSION.tar.gz\", \"aws_region\":\"$AWS_REGION\"}" --region $AWS_REGION
