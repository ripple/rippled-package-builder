#!/bin/bash -ex

mkdir rpms
aws s3 cp s3://rippled-rpms/$YUM_REPO/$s3key .
tar -zxvf $s3key -C rpms
s3_md5sum="$(rpm -Kv rpms/*.x86_64.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+')"


if [ "$md5sum" != "$s3_md5sum" ]; then
  echo -e "\nChecksum failed!"
  echo -e "\nExiting....."
  exit 1
else
  echo -e "\nChecksum passed!"
fi

echo -e "\nSigning the RPMs"
rpm --addsign rpms/*.rpm

echo -e "\nCopying rpm and source rpm"
scp -i ~/.ssh/release-key2 rpms/rippled-* jenkins@$YUM_REPO_ADDRESS:/home/jenkins/
ssh -i ~/.ssh/release-key2 jenkins@$YUM_REPO_ADDRESS "sudo cp rippled-* /var/packages/rpm/el7/$YUM_REPO/x86_64/"

echo -e "\nRe-indexing rpm repository"
ssh -i ~/.ssh/release-key2 jenkins@$YUM_REPO_ADDRESS "sudo createrepo /var/packages/rpm/el7/$YUM_REPO/x86_64"

rm -r rpms/
