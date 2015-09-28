FROM centos:latest
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm
COPY rippled.spec ./
COPY build_rpm.sh ./

RUN rpm -Uvh http://mirrors.ripple.com/ripple-repo-el7.rpm && \
    yum update -y && \
    yum install -y --enablerepo=ripple-stable rpmdevtools krb5-devel zlib-devel gcc gcc-c++ wget libstdc++-devel bzip2-devel python-devel libicu-devel chrpath scons protobuf-devel ripple-boost ripple-boost-devel ripple-openssl-devel openssl-devel ripple-boost-coroutine && \
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS} && \
    echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros && \
    ln -s /opt/ripple/boost/include/boost /usr/include/boost && \
    ln -s /opt/ripple/boost/lib/* /lib64/ && \
    ldconfig

CMD ./build_rpm.sh rippled.spec
