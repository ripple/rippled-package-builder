FROM centos:latest

RUN rpm -Uvh http://mirrors.rippletest.net/ripple-repo-el7.rpm && \
    cat /etc/yum.repos.d/ripple.repo &&\
    yum repolist
RUN yum update -y
RUN yum groupinstall -y "Development Tools"
RUN curl --silent --location https://rpm.nodesource.com/setup | bash -
RUN yum install -y yum-utils nodejs 
RUN yum install -y --enablerepo=ripple-stable rippled

RUN yumdownloader --source --enablerepo=ripple-stable rippled
RUN rpm -i rippled-*.src.rpm
RUN tar -zxf ~/rpmbuild/SOURCES/rippled.tar.gz -C ./
RUN npm --prefix ./rippled install ./rippled
RUN mkdir rippled/build
RUN ln -s /opt/ripple/bin/rippled rippled/build/rippled

VOLUME /var/lib/rippled

EXPOSE 51235/tcp
EXPOSE 5005/tcp
EXPOSE 6006/tcp

CMD /opt/ripple/bin/rippled --conf=/opt/ripple/etc/rippled/rippled.cfg
