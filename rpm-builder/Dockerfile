FROM fedora:27
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

RUN yum install -y boost-static openssl-static protobuf-static gcc-c++ libstdc++-static git zlib-static cmake rpm-build gnupg

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN git clone https://github.com/ripple/rippled.git

RUN git clone https://github.com/ripple/validator-keys-tool.git

COPY rippled.spec ./
COPY rippled.service /root/rpmbuild/SOURCES/
COPY 50-rippled.preset /root/rpmbuild/SOURCES/
COPY update-rippled.sh /root/rpmbuild/SOURCES/
COPY nofile_limit.conf /root/rpmbuild/SOURCES/

COPY build_rpm.sh ./
CMD ./build_rpm.sh
