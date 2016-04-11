#!/bin/bash
set -e

# build centos7 rpm
docker run -e GIT_BRANCH=release -v $PWD/test/:/opt/rippled-rpm/out rippled-rpm-builder-centos7

# source properties
. test/build_vars

# test centos7 rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" \
-e "RIPPLED_VERSION=$rippled_version" \
-e "RPM_MD5SUM=$rpm_md5sum" \
-e "DBG_MD5SUM=$dbg_md5sum" \
-e "SRC_MD5SUM=$src_md5sum" \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_centos7_rpm.sh \
-w /opt/rippled \
centos:latest
