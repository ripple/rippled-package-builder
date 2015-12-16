%define rippled_version %(echo $RIPPLED_RPM_VERSION)
%define         debug_package %{nil}
%define _prefix /opt/ripple
Name:           rippled
# Dashes in Version extensions must be converted to underscores
Version:        %{rippled_version}
Release:        1%{?dist}
Summary:        rippled daemon

License:        MIT
URL:            http://ripple.com/
Source0:        rippled.tar.gz
Source1:        rippled.service
Source2:        50-rippled.preset
Source3:        wrapper.sh

BuildRequires:  scons ripple-boost-devel protobuf-devel ripple-openssl-devel
Requires:       ripple-openssl-libs

%description
rippled

%prep
%setup -n rippled

%build
if [[ $RIPPLED_RPM_VERSION == "0.30.0"* ]]; then
  RIPPLED_OLD_GCC_ABI=1 scons %{?_smp_mflags}
else
  RIPPLED_OLD_GCC_ABI=0 scons %{?_smp_mflags} --static
fi

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_prefix}/
echo "Installing to /opt/ripple/"
install -D doc/rippled-example.cfg ${RPM_BUILD_ROOT}%{_prefix}/etc/rippled.cfg
install -d ${RPM_BUILD_ROOT}/etc/opt/ripple
ln -s %{_prefix}/etc/rippled.cfg ${RPM_BUILD_ROOT}/etc/opt/ripple/rippled.cfg
install -D build/gcc.release/rippled ${RPM_BUILD_ROOT}%{_bindir}/rippled
install -D %{SOURCE1} ${RPM_BUILD_ROOT}/usr/lib/systemd/system/rippled.service
install -D %{SOURCE2} ${RPM_BUILD_ROOT}/usr/lib/systemd/system-preset/50-rippled.preset
install -D %{SOURCE3} ${RPM_BUILD_ROOT}%{_bindir}/wrapper.sh

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
%doc README.md LICENSE
%{_bindir}/rippled
%{_bindir}/wrapper.sh
%config(noreplace) %{_prefix}/etc/rippled.cfg
%config(noreplace) /etc/opt/ripple/rippled.cfg
%config(noreplace) /usr/lib/systemd/system/rippled.service
%config(noreplace) /usr/lib/systemd/system-preset/50-rippled.preset
%dir /var/log/rippled/
%dir /var/lib/rippled/

%changelog
