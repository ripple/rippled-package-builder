FROM centos:latest
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm
COPY rippled.spec ./
COPY build_rpm.sh ./

RUN rpm -Uvh http://mirrors.ripple.com/ripple-repo-el7.rpm
RUN yum update -y
RUN yum install -y --enablerepo=ripple-stable rpmdevtools krb5-devel zlib-devel gcc gcc-c++ wget libstdc++-devel bzip2-devel python-devel libicu-devel chrpath scons protobuf-devel ripple-boost ripple-boost-devel ripple-openssl-devel openssl-devel ripple-boost-coroutine

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN cp build-against-ripple-libs.patch ~/rpmbuild/SOURCES/
RUN ln -s /opt/ripple/boost/include/boost /usr/include/boost
RUN ln -s /opt/ripple/boost/lib/* /lib64/
RUN ldconfig

RUN yum -y install epel-release
RUN yum -y install python-pip
RUN pip install awscli

CMD ./build_rpm.sh rippled.spec
