#!/bin/bash
set -e

# build centos6 rpm
docker run -e GIT_BRANCH=release -v $PWD/test/:/opt/rippled-rpm/out rippled-rpm-builder-centos6

# source properties
. test/build_vars

# test centos6 rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" \
-e "RIPPLED_VERSION=$rippled_version" \
-e "MD5SUM=$md5sum" \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_centos6_rpm.sh \
-w /opt/rippled \
centos:6
