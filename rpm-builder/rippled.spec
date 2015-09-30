%define rippled_branch %(echo $RIPPLED_BRANCH)
%define         debug_package %{nil}
%define _prefix /opt/ripple
Name:           rippled
# Version must be limited to MAJOR.MINOR.PATCH
Version:        0.29.1
# Release should include either the build or hotfix number (ex: hf1%{?dist} or b2%{?dist})
# If there is no b# or hf#, then use 1%{?dist}
Release:        rc1%{?dist}
Summary:        rippled daemon

License:        MIT
URL:            http://ripple.com/
Source0:        rippled-%{rippled_branch}.zip
Source1:        rippled.service
Source2:        50-rippled.preset
Patch0:         build-against-ripple-libs.patch

BuildRequires:  scons ripple-boost-devel protobuf-devel ripple-openssl-devel
Requires:       ripple-openssl-libs

%description
rippled

%prep
%setup -n rippled-%{rippled_branch}
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
