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

VERSION=$(egrep -i -o "\b(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9a-z\-]+(\.[0-9a-z\-]+)*)?(\+[0-9a-z\-]+(\.[0-9a-z\-]+)*)?\b" src/ripple/protocol/impl/BuildInfo.cpp)

IFS=- read -r RIPPLED_VERSION RIPPLED_RELEASE <<< "$VERSION"

if [ -z "$RIPPLED_RELEASE" ]; then
  RIPPLED_RELEASE=1
fi

export RIPPLED_VERSION
export RIPPLED_RELEASE

cd ..

tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/

rpmbuild -ba $1

aws s3 cp --recursive ~/rpmbuild/RPMS/x86_64/ s3://rpm-builder-test
aws s3 cp --recursive ~/rpmbuild/SRPMS/ s3://rpm-builder-test
