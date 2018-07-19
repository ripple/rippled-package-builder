FROM fedora:28
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

RUN yum install -y openssl-static protobuf-static gcc-c++ libstdc++-static git zlib-static cmake rpm-build gnupg wget which make

RUN wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz && \
    tar -xzf boost_1_67_0.tar.gz && \
    cd boost_1_67_0 && \
    ./bootstrap.sh && \
    ./b2 link=static -j2 install && \
    cd .. && \
    rm boost_1_67_0.tar.gz && \
    rm -r boost_1_67_0

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
