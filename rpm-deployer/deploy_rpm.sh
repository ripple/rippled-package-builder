#!/bin/bash

function error {
  echo $1
  aws sqs send-message --queue-url $SQS_QUEUE_FAILED --message-body "{\"stage\":\"rpm-deployer\", \"error\":\"$1\", \"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
  exit 1
}

cd /home/docker/rpm-deployer/ansible

mkdir rpms

aws s3 cp s3://$S3_BUCKET/$S3_KEY . --region $S3_REGION
rc=$?; if [[ $rc != 0 ]]; then
  error "error downloading rpm from s3://$S3_BUCKET/$S3_KEY"
fi

tar -zxvf $S3_KEY -C rpms

# Check rpm's md5sum
S3_MD5SUM=`rpm -Kv rpms/*.x86_64.rpm | grep 'MD5 digest' | grep -oP '\(\K[^)]+'`
if [ "$S3_MD5SUM" != "$MD5SUM" ]; then
  error "md5sum mismatch ($S3_MD5SUM)"
fi

if [ -z "$STAGING_YUM_HOST" ]; then
  error "missing STAGING_YUM_HOST"
elif [ -z "$STAGING_YUM_USER" ]; then
  error "missing STAGING_YUM_USER"
fi

if [ -z "$STAGING_YUM_PEM_FILE" ]; then
  ansible-playbook -e yum_repo=${YUM_REPO/ripple-/} -e remote_user=$STAGING_YUM_USER -vvv -i $STAGING_YUM_HOST, staging.yml
else
  ansible-playbook -e yum_repo=${YUM_REPO/ripple-/} -e remote_user=$STAGING_YUM_USER -e ansible_ssh_private_key_file=$STAGING_YUM_PEM_FILE -vvv -i $STAGING_YUM_HOST, staging.yml
fi

rc=$?; if [[ $rc != 0 ]]; then
  error "error deploying to $YUM_REPO with ansible"
fi

aws sqs send-message --queue-url $SQS_QUEUE_DEPLOYED --message-body "{\"yum_repo\":\"$YUM_REPO\", \"commit_hash\":\"$COMMIT_HASH\", \"md5sum\":\"$MD5SUM\", \"rippled_version\":\"$RIPPLED_VERSION\", \"commit_signer\":\"$COMMIT_SIGNER\"}" --region $SQS_REGION
rc=$?; if [[ $rc != 0 ]]; then
  error "error sending message to $SQS_QUEUE_DEPLOYED"
fi
