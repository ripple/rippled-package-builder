FROM ubuntu:latest

RUN sudo apt-get -qq install software-properties-common
RUN sudo add-apt-repository -y ppa:ansible/ansible
RUN sudo apt-get -qq update
RUN sudo apt-get -qq install ansible

# sync the file from s3 to the mirrors.rippletest.net
# run createrepo to re-index the rpm repository
# spawn a docker container that tests the new rpm

