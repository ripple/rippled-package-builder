#!/bin/bash
set -e

rm -f test/build_vars

# build rpm
docker build -t rippled-rpm-builder-pre-0.30.1 rpm-builder/
docker run -e GIT_BRANCH=master -v $PWD/test/:/opt/rippled-rpm/out rippled-rpm-builder-pre-0.30.1

# source properties
. test/build_vars

# test rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" \
-e "RIPPLED_VERSION=$rippled_version" \
-e "MD5SUM=$md5sum" \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_rpm.sh \
-w /opt/rippled \
centos:latest
