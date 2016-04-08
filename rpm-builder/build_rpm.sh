#!/bin/bash

function error {
  echo $1
  exit 1
}

GIT_BRANCH=${GIT_BRANCH-develop}
RPM_RELEASE=${RPM_RELEASE-1}
export RPM_RELEASE

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

# Make a tar of the rpm and source rpm
tar_file=$RIPPLED_VERSION-$RPM_RELEASE.tar.gz
tar -zvcf $tar_file -C ~/rpmbuild/RPMS/x86_64/ . -C ~/rpmbuild/SRPMS/ .
cp $tar_file /opt/rippled-rpm/out/

RPM_MD5SUM=`rpm -Kv ~/rpmbuild/RPMS/x86_64/rippled-[0-9]*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
DBG_MD5SUM=`rpm -Kv ~/rpmbuild/RPMS/x86_64/rippled-debuginfo*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
SRC_MD5SUM=`rpm -Kv ~/rpmbuild/SRPMS/*.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`

echo "rpm_md5sum=$RPM_MD5SUM" > /opt/rippled-rpm/out/build_vars
echo "dbg_md5sum=$DBG_MD5SUM" >> /opt/rippled-rpm/out/build_vars
echo "src_md5sum=$SRC_MD5SUM" >> /opt/rippled-rpm/out/build_vars
echo "rippled_version=$RIPPLED_RPM_VERSION" >> /opt/rippled-rpm/out/build_vars
echo "rpm_file_name=$tar_file" >> /opt/rippled-rpm/out/build_vars
