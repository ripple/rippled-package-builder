%define rippled_version %(echo $RIPPLED_VERSION)
%define rippled_release %(echo $RIPPLED_RELEASE)
%define         debug_package %{nil}
%define _prefix /opt/ripple
Name:           rippled
Version:        %{rippled_version}
Release:        %{rippled_release}%{?dist}
Summary:        rippled daemon

License:        MIT
URL:            http://ripple.com/
Source0:        rippled.tar.gz
Source1:        rippled.service
Source2:        50-rippled.preset
Patch0:         build-against-ripple-libs.patch

BuildRequires:  scons ripple-boost-devel protobuf-devel ripple-openssl-devel
Requires:       ripple-openssl-libs

%description
rippled

%prep
%setup -n rippled
%patch0 -p 1

%build
export PKG_CONFIG_PATH=%{_prefix}/openssl/lib/pkgconfig
OPENSSL_ROOT=%{_prefix}/openssl BOOST_ROOT=%{_prefix}/boost/ scons %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_prefix}/
echo "Installing to /opt/ripple/"
install -D doc/rippled-example.cfg ${RPM_BUILD_ROOT}%{_prefix}/etc/rippled.cfg
install -D build/gcc.release/rippled ${RPM_BUILD_ROOT}%{_bindir}/rippled
install -D %{SOURCE1} ${RPM_BUILD_ROOT}/usr/lib/systemd/system/rippled.service
install -D %{SOURCE1} ${RPM_BUILD_ROOT}/usr/lib/systemd/system-preset/50-rippled.preset

%files
%doc README.md LICENSE
%{_bindir}/rippled
%config(noreplace) %{_prefix}/etc/rippled.cfg
/usr/lib/systemd/system/rippled.service
/usr/lib/systemd/system-preset/50-rippled.preset

%changelog
