#!/bin/bash

function error {
  echo $1
  exit 1
}

GIT_REMOTE=${GIT_REMOTE-origin}

if [ -z ${GIT_COMMIT+x} ]; then
  GIT_BRANCH=${GIT_REMOTE}/${GIT_BRANCH-develop}
else
  GIT_BRANCH=$GIT_COMMIT
fi

cd rippled

if [ "$GIT_REMOTE" != "origin" ]; then
  git remote add $GIT_REMOTE https://github.com/$GIT_REMOTE/rippled.git
fi

git fetch $GIT_REMOTE
rc=$?; if [[ $rc != 0 ]]; then
  error "error fetching $GIT_REMOTE"
fi

git checkout $GIT_BRANCH
rc=$?; if [[ $rc != 0 ]]; then
  error "error checking out $GIT_BRANCH"
fi
git pull

# Import rippled dev public keys
gpg --import /opt/rippled-rpm/public-keys.txt

# Verify git commit signature
COMMIT_SIGNER=`git verify-commit HEAD 2>&1 >/dev/null | grep 'Good signature from' | grep -oP '\"\K[^"]+'`
if [ -z "$COMMIT_SIGNER" ]; then
  error "git commit signature verification failed"
fi
RIPPLED_VERSION=$(egrep -i -o "\b(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9a-z\-]+(\.[0-9a-z\-]+)*)?(\+[0-9a-z\-]+(\.[0-9a-z\-]+)*)?\b" src/ripple/protocol/impl/BuildInfo.cpp)

IFS='-' read -r RIPPLED_RPM_VERSION RELEASE <<< "$RIPPLED_VERSION"
export RIPPLED_RPM_VERSION

RPM_RELEASE=${RPM_RELEASE-1}

# post-release version
if [ "hf" = "$(echo "$RELEASE" | cut -c -2)" ]; then
  RPM_RELEASE="${RPM_RELEASE}.${RELEASE}"
# pre-release version (-b or -rc)
elif [[ $RELEASE ]]; then
  RPM_RELEASE="0.${RPM_RELEASE}.${RELEASE}"
fi

export RPM_RELEASE

if [[ $RPM_PATCH ]]; then
  RPM_PATCH=".${RPM_PATCH}"
  export RPM_PATCH
fi

# Build the rpm
cd ..

tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/

rpmbuild -ba rippled.spec
rc=$?; if [[ $rc != 0 ]]; then
  error "error building rpm"
fi

# Make a tar of the rpm and source rpm
tar_file=$RIPPLED_VERSION$RPM_PATCH.tar.gz
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
