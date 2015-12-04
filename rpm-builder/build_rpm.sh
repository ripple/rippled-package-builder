#!/bin/bash

function error {
  echo $1
  exit 1
}

cd rippled
git fetch origin

git checkout $GIT_BRANCH
rc=$?; if [[ $rc != 0 ]]; then
  error "error checking out $GIT_BRANCH"
fi
git pull

# Verify git commit signature
COMMIT_SIGNER=`git verify-commit HEAD 2>&1 >/dev/null | grep 'Good signature from' | grep -oP '\"\K[^"]+'`
if [ -z "$COMMIT_SIGNER" ]; then
  error "git commit signature verification failed"
fi
RIPPLED_VERSION=$(egrep -i -o "\b(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9a-z\-]+(\.[0-9a-z\-]+)*)?(\+[0-9a-z\-]+(\.[0-9a-z\-]+)*)?\b" src/ripple/protocol/impl/BuildInfo.cpp)

# Convert dashes to underscores in rippled version for rpm compatibility
RIPPLED_RPM_VERSION=`echo "$RIPPLED_VERSION" | tr - _`
export RIPPLED_RPM_VERSION

# Build the rpm
cd ..

tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/

rpmbuild -ba rippled.spec
rc=$?; if [[ $rc != 0 ]]; then
  error "error building rpm"
fi

# Upload a tar of the rpm and source rpm to s3
tar -zvcf $RIPPLED_VERSION.tar.gz -C ~/rpmbuild/RPMS/x86_64/ . -C ~/rpmbuild/SRPMS/ .
aws s3 cp $RIPPLED_VERSION.tar.gz s3://$S3_BUCKET --region $S3_REGION
rc=$?; if [[ $rc != 0 ]]; then
  error "error uploading $RIPPLED_VERSION.tar.gz to s3://$S3_BUCKET"
fi

MD5SUM=`rpm -Kv ~/rpmbuild/RPMS/x86_64/*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`

echo "md5sum=$MD5SUM" >> /opt/rippled-rpm/out/build_vars
echo "rippled_version=$RIPPLED_RPM_VERSION" >> /opt/rippled-rpm/out/build_vars
echo "s3key=$RIPPLED_VERSION.tar.gz" >> /opt/rippled-rpm/out/build_vars
