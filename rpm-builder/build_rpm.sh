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

# fetch again, including remotes...but ok if this fails for some reason
git fetch $GIT_REMOTE "+refs/pull/*/head:refs/remotes/origin/pr/*"

git checkout $GIT_BRANCH
rc=$?; if [[ $rc != 0 ]]; then
  error "error checking out $GIT_BRANCH"
fi
git pull

# Import rippled dev public keys
if [ -e /opt/rippled-rpm/public-keys.txt ]; then
  gpg --import /opt/rippled-rpm/public-keys.txt

  # Verify git commit signature
  COMMIT_SIGNER=`git verify-commit HEAD 2>&1 >/dev/null | grep 'Good signature from' | grep -oP '\"\K[^"]+'`
  if [ -z "$COMMIT_SIGNER" ]; then
    error "rippled git commit signature verification failed"
  fi
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

cd ../validator-keys-tool
git fetch origin
git checkout origin/master

if [ -e /opt/rippled-rpm/public-keys.txt ]; then
  # Verify git commit signature
  COMMIT_SIGNER=`git verify-commit HEAD 2>&1 >/dev/null | grep 'Good signature from' | grep -oP '\"\K[^"]+'`
  if [ -z "$COMMIT_SIGNER" ]; then
    error "validator-keys git commit signature verification failed"
  fi
fi

git submodule update --init --recursive

# Build the rpm
cd ..

tar -zcf ~/rpmbuild/SOURCES/rippled.tar.gz rippled/
tar -zcf ~/rpmbuild/SOURCES/validator-keys.tar.gz validator-keys-tool/

rpmbuild -ba rippled.spec
rc=$?; if [[ $rc != 0 ]]; then
  error "error building rpm"
fi

# Make a tar of the rpm and source rpm
RPM_VERSION_RELEASE=`rpm -qp --qf='%{NAME}-%{VERSION}-%{RELEASE}' ~/rpmbuild/RPMS/x86_64/rippled-[0-9]*.rpm`
tar_file=$RPM_VERSION_RELEASE.tar.gz

tar -zvcf $tar_file -C ~/rpmbuild/RPMS/x86_64/ . -C ~/rpmbuild/SRPMS/ .
cp $tar_file /opt/rippled-rpm/out/

RPM_MD5SUM=`rpm -q --queryformat '%{SIGMD5}\n' ~/rpmbuild/RPMS/x86_64/rippled-[0-9]*.rpm 2> /dev/null`
DBG_MD5SUM=`rpm -q --queryformat '%{SIGMD5}\n' ~/rpmbuild/RPMS/x86_64/rippled-debuginfo*.rpm 2> /dev/null`
DEV_MD5SUM=`rpm -q --queryformat '%{SIGMD5}\n' ~/rpmbuild/RPMS/x86_64/rippled-devel*.rpm 2> /dev/null`
SRC_MD5SUM=`rpm -q --queryformat '%{SIGMD5}\n' ~/rpmbuild/SRPMS/*.rpm 2> /dev/null`

RPM_SHA256="$(sha256sum ~/rpmbuild/RPMS/x86_64/rippled-[0-9]*.rpm | awk '{ print $1}')"
DBG_SHA256="$(sha256sum ~/rpmbuild/RPMS/x86_64/rippled-debuginfo*.rpm | awk '{ print $1}')"
DEV_SHA256="$(sha256sum ~/rpmbuild/RPMS/x86_64/rippled-devel*.rpm | awk '{ print $1}')"
SRC_SHA256="$(sha256sum ~/rpmbuild/SRPMS/*.rpm | awk '{ print $1}')"

echo "rpm_md5sum=$RPM_MD5SUM" > /opt/rippled-rpm/out/build_vars
echo "dbg_md5sum=$DBG_MD5SUM" >> /opt/rippled-rpm/out/build_vars
echo "dev_md5sum=$DEV_MD5SUM" >> /opt/rippled-rpm/out/build_vars
echo "src_md5sum=$SRC_MD5SUM" >> /opt/rippled-rpm/out/build_vars
echo "rpm_sha256=$RPM_SHA256" >> /opt/rippled-rpm/out/build_vars
echo "dbg_sha256=$DBG_SHA256" >> /opt/rippled-rpm/out/build_vars
echo "dev_sha256=$DEV_SHA256" >> /opt/rippled-rpm/out/build_vars
echo "src_sha256=$SRC_SHA256" >> /opt/rippled-rpm/out/build_vars
echo "rippled_version=$RIPPLED_RPM_VERSION" >> /opt/rippled-rpm/out/build_vars
echo "rpm_file_name=$tar_file" >> /opt/rippled-rpm/out/build_vars
echo "rpm_version_release=$RPM_VERSION_RELEASE" >> /opt/rippled-rpm/out/build_vars
