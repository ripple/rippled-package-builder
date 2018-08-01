%define rippled_version %(echo $RIPPLED_RPM_VERSION)
%define rpm_release %(echo $RPM_RELEASE)
%define rpm_patch %(echo $RPM_PATCH)
%define _prefix /opt/ripple
Name:           rippled
# Dashes in Version extensions must be converted to underscores
Version:        %{rippled_version}
Release:        %{rpm_release}%{?dist}%{rpm_patch}
Summary:        rippled daemon

License:        MIT
URL:            http://ripple.com/
Source0:        rippled.tar.gz
Source1:        validator-keys.tar.gz
Source2:        rippled.service
Source3:        50-rippled.preset
Source4:        update-rippled.sh
Source5:        nofile_limit.conf

BuildRequires:  protobuf-static openssl-static cmake zlib-static

%description
rippled

%package devel
Summary: Files for development of applications using xrpl core library
Group: Development/Libraries
Requires: openssl-static%{?_isa}, zlib-static%{?_isa}

%description devel
core library for development of standalone applications that sign transactions.

%prep
%setup -c -n rippled -a 1

%build
cd rippled
mkdir -p build/gcc.release
cd build/gcc.release
cmake ../.. -DCMAKE_INSTALL_PREFIX=%{_prefix} -DCMAKE_BUILD_TYPE=Release -Dstatic=true -DCMAKE_VERBOSE_MAKEFILE=ON
cmake --build . -- -j 2 verbose=1

cd ../../../validator-keys-tool
mkdir -p build/gcc.release
cd build/gcc.release
cmake ../.. -DCMAKE_BUILD_TYPE=Release -Dtarget=gcc.release -Dstatic=true -DCMAKE_VERBOSE_MAKEFILE=ON
cmake --build . -- -j 2 verbose=1

%pre
test -e /etc/pki/tls || { mkdir -p /etc/pki; ln -s /usr/lib/ssl /etc/pki/tls; }

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_prefix}/
echo "Installing to /opt/ripple/"
cd rippled/build/gcc.release
make DESTDIR=$RPM_BUILD_ROOT install
cd ../../..
install -d ${RPM_BUILD_ROOT}/etc/opt/ripple
ln -s %{_prefix}/etc/rippled.cfg ${RPM_BUILD_ROOT}/etc/opt/ripple/rippled.cfg
ln -s %{_prefix}/etc/validators.txt ${RPM_BUILD_ROOT}/etc/opt/ripple/validators.txt
install -D validator-keys-tool/build/gcc.release/validator-keys ${RPM_BUILD_ROOT}%{_bindir}/validator-keys
install -D %{SOURCE2} ${RPM_BUILD_ROOT}/usr/lib/systemd/system/rippled.service
install -D %{SOURCE3} ${RPM_BUILD_ROOT}/usr/lib/systemd/system-preset/50-rippled.preset
install -D %{SOURCE4} ${RPM_BUILD_ROOT}%{_bindir}/update-rippled.sh
install -d ${RPM_BUILD_ROOT}/etc/systemd/system/rippled.service.d/
install -D %{SOURCE5} ${RPM_BUILD_ROOT}/etc/systemd/system/rippled.service.d/nofile_limit.conf

install -d $RPM_BUILD_ROOT/var/log/rippled
install -d $RPM_BUILD_ROOT/var/lib/rippled

%post
USER_NAME=rippled
GROUP_NAME=rippled

getent passwd $USER_NAME &>/dev/null || useradd $USER_NAME
getent group $GROUP_NAME &>/dev/null || groupadd $GROUP_NAME

chown -R $USER_NAME:$GROUP_NAME /var/log/rippled/
chown -R $USER_NAME:$GROUP_NAME /var/lib/rippled/
chown -R $USER_NAME:$GROUP_NAME %{_prefix}/

chmod 755 /var/log/rippled/
chmod 755 /var/lib/rippled/

%files
%doc rippled/README.md rippled/LICENSE
%{_bindir}/rippled
%{_bindir}/update-rippled.sh
%{_bindir}/validator-keys
%config(noreplace) %{_prefix}/etc/rippled.cfg
%config(noreplace) /etc/opt/ripple/rippled.cfg
%config(noreplace) %{_prefix}/etc/validators.txt
%config(noreplace) /etc/opt/ripple/validators.txt
%config(noreplace) /usr/lib/systemd/system/rippled.service
%config(noreplace) /usr/lib/systemd/system-preset/50-rippled.preset
%config(noreplace) /etc/systemd/system/rippled.service.d/nofile_limit.conf
%dir /var/log/rippled/
%dir /var/lib/rippled/

%files devel
%{_prefix}/include
%{_prefix}/lib/*.a
%{_prefix}/lib/cmake/ripple

%changelog
* Wed Aug 01 2018 Mike Ellery <mellery451@gmail.com>
- add devel package for signing library

* Thu Jun 02 2016 Brandon Wilson <bwilson@ripple.com>
- Install validators.txt

