#!/bin/bash
set -e

# build rpm
docker build -t rippled-rpm-builder rpm-builder/
docker run -e GIT_BRANCH=develop -v $PWD/test/:/opt/rippled-rpm/out rippled-rpm-builder

# source properties
. test/build_vars

# test  rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" \
-e "RIPPLED_VERSION=$rippled_version" \
-e "RPM_MD5SUM=$rpm_md5sum" \
-e "DBG_MD5SUM=$dbg_md5sum" \
-e "DEV_MD5SUM=$dev_md5sum" \
-e "SRC_MD5SUM=$src_md5sum" \
-e "RPM_SHA256=$rpm_sha256" \
-e "DBG_SHA256=$dbg_sha256" \
-e "DEV_SHA256=$dev_sha256" \
-e "SRC_SHA256=$src_sha256" \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_rpm.sh \
-w /opt/rippled \
centos:latest

# test Ubuntu 16.04 rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" --rm \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_ubuntu_rpm.sh \
-w /opt/rippled \
ubuntu:16.04

# test Ubuntu 17.10 rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" --rm \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_ubuntu_rpm.sh \
-w /opt/rippled \
ubuntu:17.10

# test Ubuntu 18.04 rpm
docker run \
-e "RPM_FILE_NAME=$rpm_file_name" --rm \
-v $PWD/test:/opt/rippled/in --entrypoint /opt/rippled/in/test_ubuntu_rpm.sh \
-w /opt/rippled \
ubuntu:18.04
