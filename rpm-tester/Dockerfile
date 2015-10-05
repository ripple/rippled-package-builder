FROM centos:latest

RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm
COPY test_rpm.sh ./

RUN rpm -Uvh http://mirrors.rippletest.net/ripple-repo-el7.rpm
RUN yum groupinstall -y "Development Tools"
RUN curl --silent --location https://rpm.nodesource.com/setup | bash -
RUN yum install -y yum-utils nodejs 

CMD ./test_rpm.sh
