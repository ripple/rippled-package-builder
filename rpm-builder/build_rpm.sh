#!/bin/bash
curl -L -o ~/rpmbuild/SOURCES/rippled-${RIPPLED_BRANCH}.zip https://github.com/ripple/rippled/archive/${RIPPLED_BRANCH}.zip
rpmbuild -bb $1
cp ~/rpmbuild/RPMS/x86_64/* ./out/
