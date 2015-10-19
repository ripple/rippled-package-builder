#!/bin/bash
git clone https://github.com/ripple/rippled.git

cd rippled

if [ -n "$COMMIT_HASH" ]; then
  git checkout $COMMIT_HASH
elif [ -n "$RELEASE_TAG" ]; then
  git checkout tags/$RELEASE_TAG
else
  echo "Missing COMMIT_HASH or RELEASE_TAG"
  exit 1
fi

RIPPLED_VERSION=$(egrep -i -o "\b(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9a-z\-]+(\.[0-9a-z\-]+)*)?(\+[0-9a-z\-]+(\.[0-9a-z\-]+)*)?\b" src/ripple/protocol/impl/BuildInfo.cpp)

RIPPLED_RPM_VERSION=`echo "$RIPPLED_VERSION" | tr - _`
export RIPPLED_RPM_VERSION

cd ..

tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/

rpmbuild -ba $1
rpmsign --key-id="Ripple Release Engineering" --addsign ~/rpmbuild/RPMS/x86_64/*.rpm ~/rpmbuild/SRPMS/*.rpm

# Upload a tar of the rpm and source rpm to s3
tar -zvcf $RIPPLED_VERSION.tar.gz -C ~/rpmbuild/RPMS/x86_64/ . -C ~/rpmbuild/SRPMS/ .

aws s3 cp $RIPPLED_VERSION.tar.gz s3://$S3_BUCKET
