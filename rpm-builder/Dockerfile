FROM centos:latest
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

RUN rpm -Uvh http://mirrors.ripple.com/ripple-repo-el7.rpm
RUN yum install -y --enablerepo=ripple-stable git rpm-sign rpmdevtools krb5-devel zlib-devel gcc gcc-c++ wget libstdc++-devel bzip2-devel python-devel libicu-devel chrpath scons protobuf-devel ripple-boost ripple-boost-devel ripple-openssl-devel openssl-devel ripple-boost-coroutine

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN ln -s /opt/ripple/boost/include/boost /usr/include/boost
RUN ln -s /opt/ripple/boost/lib/* /lib64/
RUN ldconfig

COPY private.key ./

RUN gpg --import private.key
RUN gpg --export -a "Ripple Release Engineering" > RPM-GPG-KEY-ripple-release
RUN rpm --import RPM-GPG-KEY-ripple-release
RUN echo "%_gpg_name root" >> ~/.rpmmacros
RUN echo "%_gpg /usr/bin/gpg" >> ~/.rpmmacros
RUN echo "%_gpg_path /root/.gnupg" >> ~/.rpmmacros

COPY run_script.sh ./
COPY build_rpm.sh ./
COPY rippled.spec ./
COPY build-against-ripple-libs.patch /root/rpmbuild/SOURCES/
COPY rippled.service /root/rpmbuild/SOURCES/
COPY 50-rippled.preset /root/rpmbuild/SOURCES/

CMD ./run_script.sh
