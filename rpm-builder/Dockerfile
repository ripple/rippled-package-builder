FROM fedora:25
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

RUN yum install -y boost-static protobuf-static gcc-c++ libstdc++-static git scons cmake rpm-build gnupg

# Build openssl without krb5 and zlib
RUN yum install -y yum-utils krb5-devel lksctp-tools-devel perl-generators
RUN yumdownloader --source openssl
RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN rpm -i openssl-*.src.rpm
COPY openssl.spec.sha256sum ./
RUN sha256sum --check openssl.spec.sha256sum
COPY openssl.spec /root/rpmbuild/SPECS/
RUN rpmbuild --nocheck -bb $(rpm -E %_specdir)/openssl.spec

RUN rpm -Uvh --force ~/rpmbuild/RPMS/x86_64/openssl-1.0.2k-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-libs-1.0.2k-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-devel-1.0.2k-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-static-1.0.2k-*.x86_64.rpm

RUN rm -r ~/rpmbuild/*
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

COPY build_rpm.sh ./
CMD ./build_rpm.sh
