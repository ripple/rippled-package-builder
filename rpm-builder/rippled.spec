%define rippled_version %(echo $RIPPLED_RPM_VERSION)
%define         debug_package %{nil}
%define _prefix /opt/ripple
Name:           rippled
# Dashes in Version extensions must be converted to underscores
Version:        %{rippled_version}
Release:        4%{?dist}
Summary:        rippled daemon

License:        MIT
URL:            http://ripple.com/
Source0:        rippled.tar.gz
Source1:        rippled.service
Source2:        50-rippled.preset
Source3:        wrapper.sh
Source4:        rippled-0.30.0.x86_64.conf

BuildRequires:  scons ripple-boost-devel protobuf-devel ripple-openssl-devel
Requires:       ripple-openssl-libs

%description
rippled

%prep
%setup -n rippled

%build
scons %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_prefix}/
echo "Installing to /opt/ripple/"
install -D doc/rippled-example.cfg ${RPM_BUILD_ROOT}%{_prefix}/etc/rippled.cfg
install -D build/gcc.release/rippled ${RPM_BUILD_ROOT}%{_bindir}/rippled
install -D %{SOURCE1} ${RPM_BUILD_ROOT}/usr/lib/systemd/system/rippled.service
install -D %{SOURCE2} ${RPM_BUILD_ROOT}/usr/lib/systemd/system-preset/50-rippled.preset
install -D %{SOURCE3} ${RPM_BUILD_ROOT}%{_bindir}/wrapper.sh
install -D %{SOURCE4} ${RPM_BUILD_ROOT}/etc/ld.so.conf.d/rippled-0.30.0.x86_64.conf

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

ldconfig

%files
%doc README.md LICENSE
%{_bindir}/rippled
%{_bindir}/wrapper.sh
%config(noreplace) %{_prefix}/etc/rippled.cfg
/usr/lib/systemd/system/rippled.service
/usr/lib/systemd/system-preset/50-rippled.preset
/etc/ld.so.conf.d/rippled-0.30.0.x86_64.conf
%dir /var/log/rippled/
%dir /var/lib/rippled/

%changelog
