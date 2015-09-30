%define rippled_branch %(echo $RIPPLED_BRANCH)
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
Patch0:         build-against-ripple-libs.patch

BuildRequires:  scons ripple-boost-devel protobuf-devel ripple-openssl-devel
Requires:       ripple-openssl-libs

%description
rippled

%prep
%setup -n rippled-%{rippled_branch}
%patch0 -p 1

%build
export PKG_CONFIG_PATH=/opt/ripple/openssl/lib/pkgconfig
OPENSSL_ROOT=/opt/ripple/openssl BOOST_ROOT=/opt/ripple/boost/ scons %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
install -D doc/rippled-example.cfg ${RPM_BUILD_ROOT}/etc/rippled/rippled.cfg
install -D build/gcc.release/rippled ${RPM_BUILD_ROOT}/%{_bindir}/rippled

%files
%doc README.md LICENSE
%{_bindir}/rippled
%{_sysconfdir}/rippled/

%changelog
