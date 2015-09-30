#!/bin/bash
curl -L -o ~/rpmbuild/SOURCES/rippled-${RIPPLED_BRANCH}.zip https://github.com/ripple/rippled/archive/${RIPPLED_BRANCH}.zip
rpmbuild -ba $1
aws s3 cp --recursive ~/rpmbuild/RPMS/x86_64/ s3://rpm-builder-test
aws s3 cp --recursive ~/rpmbuild/SRPMS/ s3://rpm-builder-test
