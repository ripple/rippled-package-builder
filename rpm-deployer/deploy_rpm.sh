#!/bin/bash
cd /home/docker/rpm-deployer/ansible

mkdir rpms
aws s3 cp s3://$S3_BUCKET/$S3_KEY . --region $S3_REGION

tar -zxvf $S3_KEY -C rpms

# Check rpm's md5sum
S3_MD5SUM=`rpm -Kv rpms/*.x86_64.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
if [ "$S3_MD5SUM" != "$MD5SUM" ]; then
  ERROR="md5sum mismatch ($S3_MD5SUM)"
else
  ansible-playbook -vvv -i hosts staging.yml

  rc=$?; if [[ $rc != 0 ]]; then
    ERROR="ansible deployment failed"
  fi
fi

if [ -n "$ERROR" ]; then
  echo $ERROR
  aws sqs send-message --queue-url $SQS_QUEUE_FAILED --message-body "{\"stage\":\"rpm-deployer\", \"error\":\"$ERROR\", \"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
  exit 1
fi

aws sqs send-message --queue-url $SQS_QUEUE_DEPLOYED --message-body "{\"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
