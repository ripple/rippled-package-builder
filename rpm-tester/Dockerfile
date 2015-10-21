FROM centos:latest

RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

RUN yum groupinstall -y "Development Tools"
RUN curl --silent --location https://rpm.nodesource.com/setup | bash -
RUN yum install -y yum-utils nodejs 
RUN rpm -Uvh https://test-mirrors.ripple.com/ripple-repo-el7.rpm

RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install awscli

COPY test_rpm.sh ./

CMD ./test_rpm.sh
