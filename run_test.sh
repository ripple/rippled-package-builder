#!/bin/bash
set -e

# build rpm
docker build -t rippled-rpm-builder rpm-builder/
docker run -e RPM_RELEASE=3 -e GIT_BRANCH=release -v $PWD/test/:/opt/rippled-rpm/out rippled-rpm-builder

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
