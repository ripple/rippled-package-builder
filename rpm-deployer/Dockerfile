FROM ubuntu:latest
WORKDIR /home/docker/rpm-deployer

RUN apt-get -qq install python2.7
RUN apt-get -qq install curl
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python2.7 get-pip.py
RUN pip install awscli
RUN apt-get -qq install rpm

RUN sudo apt-get -qq install software-properties-common
RUN sudo add-apt-repository -y ppa:ansible/ansible
RUN sudo apt-get -qq update
RUN sudo apt-get -qq install ansible

COPY ./ /home/docker/rpm-deployer

# This is a workaround for 'Host key verification failed' error from ansible-playbook
RUN mkdir /root/.ssh
COPY ssh-config /root/.ssh/config
RUN chmod 600 /root/.ssh/config

CMD ./deploy_rpm.sh
