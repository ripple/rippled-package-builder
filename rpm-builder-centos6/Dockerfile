FROM centos:6
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

# Update binutils
RUN yum install -y wget gcc-c++ file rpm-build texinfo gettext bison zlib-devel dejagnu zlib-static glibc-static sharutils bc flex tar
RUN wget -c https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/19/SRPMS/binutils-2.23.52.0.1-9.fc19.src.rpm
RUN rpm -i binutils-2.23.52.0.1-9.fc19.src.rpm
RUN rpmbuild -ba ~/rpmbuild/SPECS/binutils.spec --without testsuite
RUN rpm -Uvh ~/rpmbuild/RPMS/x86_64/binutils*

# Install gcc 4.8 for Boost's libquadmath dependency
# Building Boost with gcc 5.2 causes undefined reference errors
RUN wget https://github.com/gcc-mirror/gcc/tarball/gcc-4_8_5-release
RUN tar -xf gcc-4_8_5-release
RUN cd gcc-mirror-gcc-cf82a59 && \
    ./contrib/download_prerequisites && \
    ./configure --prefix=/usr --disable-multilib --disable-bootstrap --enable-languages=c,c++ && \
    make -j `nproc` && \
    make install

# Build Boost 1.60 rpm from Fedora Rawhide source rpm
RUN wget -r -l1 -nd -A 'boost-1.60.*.src.rpm' http://mirror.utexas.edu/fedora/linux/development/rawhide/source/SRPMS/b/

RUN yum install -y libstdc++-devel bzip2-devel python-devel libicu-devel which openmpi-devel mpich-devel m4

RUN yum install -y https://centos6.iuscommunity.org/ius-release.rpm
RUN yum install -y python34u-devel

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN rpm -i boost-1.60.*.src.rpm
COPY boost.spec /root/rpmbuild/SPECS/boost.spec
RUN rpmbuild -ba ~/rpmbuild/SPECS/boost.spec --nodeps

# Install boost
RUN rm ~/rpmbuild/RPMS/x86_64/boost-doctools*
RUN rpm -ivh ~/rpmbuild/RPMS/x86_64/boost-*  --nodeps

# Build OpenSSL rpm with secp256k1 curve support
RUN yum install -y util-linux-ng krb5-devel
RUN wget http://vault.centos.org/6.7/os/Source/SPackages/openssl-1.0.1e-42.el6.src.rpm

RUN rpm -i openssl-1.0.1e*.src.rpm
COPY ec_curve.c /root/rpmbuild/SOURCES/
RUN echo "%define debug_package %{nil}" > new.spec
RUN cat ~/rpmbuild/SPECS/openssl.spec >> new.spec
RUN mv new.spec ~/rpmbuild/SPECS/openssl.spec
RUN rpmbuild -bb $(rpm -E %_specdir)/openssl.spec

# Install openssl
RUN rpm -Uvh --force ~/rpmbuild/RPMS/x86_64/openssl-1.0.1e-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-devel-1.0.1e-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/openssl-static-1.0.1e-*.x86_64.rpm

# Install protobuf
RUN yum install -y protobuf-devel protobuf-static

# Install scons 2.2
RUN wget -c https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/17/SRPMS/scons-2.2.0-1.fc17.src.rpm
RUN rpm -i scons-2.2.0-1.fc17.src.rpm
RUN rpmbuild -ba ~/rpmbuild/SPECS/scons.spec
RUN rpm -Uvh ~/rpmbuild/RPMS/noarch/scons*

# Update git
RUN yum install -y rpm-sign autoconf libstdc++-devel chrpath curl-devel expat-devel gettext-devel perl-devel libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
RUN cd /usr/src && \
    wget https://www.kernel.org/pub/software/scm/git/git-2.6.2.tar.gz && \
    tar xzf git-2.6.2.tar.gz --owner root --group root --no-same-owner && \
    cd git-2.6.2 && \
    make configure && \
    ./configure --prefix=/usr && \
    make all && \
    make install

# Install gcc 5.2
RUN wget https://github.com/gcc-mirror/gcc/tarball/gcc-5_2_0-release
RUN tar -xf gcc-5_2_0-release
RUN cd gcc-mirror-gcc-7b26e38 && \
    ./contrib/download_prerequisites && \
    ./configure --prefix=/usr --disable-multilib --disable-bootstrap --enable-languages=c,c++ && \
    make -j `nproc` && \
    make install

RUN rm -r ~/rpmbuild/*
RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

RUN git clone https://github.com/ripple/rippled.git

# Install python 2.7
RUN wget -c https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz
RUN tar xf Python-2.7.6.tar.xz
RUN cd Python-2.7.6 && \
    ./configure --prefix=/usr/local && \
    make && make install

COPY rippled.spec ./
COPY rippled.service /root/rpmbuild/SOURCES/
COPY 50-rippled.preset /root/rpmbuild/SOURCES/

# Import rippled dev public keys
COPY public-keys.txt ./
RUN gpg --import public-keys.txt

COPY build_rpm.sh ./
CMD ./build_rpm.sh
