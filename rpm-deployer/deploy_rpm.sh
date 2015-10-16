#!/bin/bash
cd /home/docker/rpm-deployer/ansible

mkdir rpms
aws s3 cp  s3://$S3_BUCKET/$S3_KEY .

tar -zxvf $S3_KEY -C rpms

ansible-playbook -vvv -i hosts staging.yml

rc=$?; if [[ $rc != 0 ]]; then
  echo "rpm deployment to staging yum repo failed"
  exit $rc
fi

aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/356003847803/rippled-rpm-deployed-staging --message-body '{"repo":"ripple-stable"}' --region $AWS_REGION
