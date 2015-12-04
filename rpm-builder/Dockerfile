FROM centos:latest
RUN mkdir /opt/rippled-rpm
WORKDIR /opt/rippled-rpm

# Update git
RUN yum groupinstall -y "Development Tools"
RUN yum install -y rpm-sign rpmdevtools krb5-devel zlib-devel gcc gcc-c++ wget libstdc++-devel bzip2-devel python-devel libicu-devel chrpath curl-devel expat-devel gettext-devel openssl-devel perl-devel libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
RUN cd /usr/src && \
    wget https://www.kernel.org/pub/software/scm/git/git-2.6.2.tar.gz && \
    tar xzf git-2.6.2.tar.gz && \
    cd git-2.6.2 && \
    make configure && \
    ./configure --prefix=/usr && \
    make all && \
    make install

# Install gcc 5.2
RUN svn co svn://gcc.gnu.org/svn/gcc/tags/gcc_5_2_0_release gcc && \
    cd gcc && \
    ./contrib/download_prerequisites && \
    ./configure --prefix=/usr --disable-multilib --enable-languages=c,c++ && \
    make -j `nproc` && \
    make install

# Use Fedora EPEL for protobuf-static
RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN rpm -ivh epel-release-7-5.noarch.rpm
RUN rpm -Uvh https://mirrors.ripple.com/ripple-repo-el7.rpm
RUN yum install -y --enablerepo=ripple-stable scons protobuf-devel protobuf-static ripple-boost ripple-boost-devel ripple-boost-static ripple-openssl-devel ripple-openssl-static openssl-devel ripple-boost-coroutine

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

# ripple-openssl-static is missing libboost_thread.a
RUN ln -s /opt/ripple/boost/lib/libboost_thread-mt.a /opt/ripple/boost/lib/libboost_thread.a

RUN ln -s /opt/ripple/boost/include/boost /usr/include/boost
RUN ln -s /opt/ripple/boost/lib/* /lib64/
RUN ln -s -f /opt/ripple/openssl/include/openssl/* /usr/include/openssl/
RUN ln -s -f /opt/ripple/openssl/lib/*.so* /lib64/
RUN ln -s -f /opt/ripple/openssl/lib/*.a /lib64/
RUN ln -s -f /opt/ripple/openssl/lib/openssl /lib64/openssl
RUN ln -s -f /opt/ripple/openssl/lib/pkgconfig/* /lib64/pkgconfig/
RUN ldconfig

RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install awscli

RUN git clone https://github.com/ripple/rippled.git

COPY build_rpm.sh ./
COPY rippled.spec ./
COPY rippled.service /root/rpmbuild/SOURCES/
COPY 50-rippled.preset /root/rpmbuild/SOURCES/
COPY wrapper.sh /root/rpmbuild/SOURCES/

CMD ./build_rpm.sh
