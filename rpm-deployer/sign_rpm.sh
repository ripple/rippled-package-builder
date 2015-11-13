#!/bin/bash -ex

echo -e "\nSigning the RPMs"
sudo rpm --addsign rpms/*.rpm