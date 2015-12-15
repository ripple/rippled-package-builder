#!/bin/bash

# build rpm
docker build -t rippled-rpm-builder rpm-builder/
docker run -e GIT_BRANCH=develop -v $PWD/test/:/opt/rippled-rpm/out rippled-rpm-builder

# source properties
. test/build_vars

echo "$md5sum"
echo "$rpm_file_name"
echo "$rippled_version"

# test rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" \
-e "RIPPLED_VERSION=$rippled_version" \
-e "MD5SUM=$md5sum" \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_rpm.sh \
-w /opt/rippled \
centos:latest
