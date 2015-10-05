FROM ubuntu:latest

RUN sudo apt-get -qq install software-properties-common
RUN sudo add-apt-repository -y ppa:ansible/ansible
RUN sudo apt-get -qq update
RUN sudo apt-get -qq install ansible

COPY ./ /home/docker/rpm-deployer

ENV AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
ENV S3_BUCKET $S3_BUCKET
ENV S3_KEY $S3_KEY

CMD cd /home/docker/rpm-deployer && ansible-playbook -vvv -i ansible/hosts ansible/staging.yml

