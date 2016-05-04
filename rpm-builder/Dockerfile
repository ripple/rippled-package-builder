FROM centos:latest
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

# Build OpenSSL rpm with secp256k1 curve support
RUN yumdownloader --source openssl

RUN yum install -y rpm-build gcc-c++ make krb5-devel zlib-devel

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN rpm -i openssl-1.0.1e*.src.rpm
COPY ec_curve.c /root/rpmbuild/SOURCES/
RUN rpmbuild -bb $(rpm -E %_specdir)/openssl.spec

# Install openssl
RUN rpm -Uvh --force ~/rpmbuild/RPMS/x86_64/openssl-1.0.1e-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-libs-1.0.1e-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-devel-1.0.1e-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-static-1.0.1e-*.x86_64.rpm

# Build Boost 1.60 rpm from Fedora Rawhide source rpm
COPY Fedora-Rawhide.repo /etc/yum.repos.d/
RUN yumdownloader --source --enablerepo=warning:rawhide boost

RUN yum install -y rpm-build libstdc++-devel bzip2-devel python-devel libicu-devel openmpi-devel mpich-devel m4 which tar
COPY Fedora-Core23.repo /etc/yum.repos.d/
RUN yum install -y --enablerepo=warning:fedora23 python3-devel

RUN rpmbuild --rebuild boost-1.60.*.src.rpm

# Install boost
RUN mkdir -p /share/CentOS/7/local/x86_64/RPMS/
RUN cp ~/rpmbuild/RPMS/x86_64/* /share/CentOS/7/local/x86_64/RPMS/
RUN rm -r ~/rpmbuild/*
RUN yum install -y createrepo
RUN createrepo /share/CentOS/7/local/x86_64/
COPY local.repo /etc/yum.repos.d/
RUN yum install -y boost boost-devel boost-static

# Use Fedora EPEL for protobuf-static
RUN yum install -y wget
RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm
RUN rpm -ivh epel-release-7-6.noarch.rpm
RUN yum install -y scons protobuf-devel protobuf-static

# Update git
RUN yum install -y rpm-sign autoconf libstdc++-devel bzip2-devel chrpath curl-devel expat-devel gettext-devel perl-devel libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
RUN cd /usr/src && \
    wget https://www.kernel.org/pub/software/scm/git/git-2.6.2.tar.gz && \
    tar xzf git-2.6.2.tar.gz --owner root --group root --no-same-owner && \
    cd git-2.6.2 && \
    make configure && \
    ./configure --prefix=/usr && \
    make all && \
    make install

# Install GCC 5
RUN yum install -y gcc gcc-c++ libstdc++-static --enablerepo=warning:fedora23

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN git clone https://github.com/ripple/rippled.git

COPY rippled.spec ./
COPY rippled.service /root/rpmbuild/SOURCES/
COPY 50-rippled.preset /root/rpmbuild/SOURCES/
COPY update-rippled.sh /root/rpmbuild/SOURCES/
COPY nofile_limit.conf /root/rpmbuild/SOURCES/

# Import rippled dev public keys
COPY public-keys.txt ./
RUN gpg --import public-keys.txt

COPY build_rpm.sh ./
CMD ./build_rpm.sh
