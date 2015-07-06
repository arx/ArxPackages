#
# spec file for package innoextract
#
# Copyright (c) 2012-2015 Daniel Scharrer <daniel@constexpr.org>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://innoextract.constexpr.org/issues
#

Name:           innoextract
Version:        1.4
Release:        1%{?dist}
%if 0%{?suse_version}
License:        Zlib
%else
License:        zlib
%endif
Summary:        Tool to extract installers created by Inno Setup
Url:            http://constexpr.org/innoextract/
%if 0%{?suse_version}
Group:          Productivity/Archiving/Compression
%else
Group:          Applications/Archiving
%endif
Source:         http://constexpr.org/innoextract/files/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
%if 0%{?suse_version}
BuildRequires:  c++_compiler
%else
BuildRequires:  gcc-c++
%endif
BuildRequires:  cmake
BuildRequires:  boost-devel
BuildRequires:  xz-devel

%description
Inno Setup is a tool to create installers for Microsoft Windows
applications. innoextract allows to extract such installers under
non-windows systems without running the actual installer using wine.

%prep
%setup -q

%build
cmake . \
	-DCMAKE_INSTALL_PREFIX=%{_prefix} \
	-DCMAKE_INSTALL_DATAROOTDIR="%{_datadir}" \
	-DCMAKE_INSTALL_MANDIR="%{_mandir}" \
	-DCMAKE_INSTALL_BINDIR="%{_bindir}" \
	-DCMAKE_CXX_FLAGS="$RPM_OPT_FLAGS"
make

%install
%make_install

%files
%license LICENSE
%doc README.md CHANGELOG VERSION
%doc %{_mandir}/man1/innoextract.1*
%{_bindir}/innoextract

%changelog
* Mon Mar 11 2013 Daniel Scharrer <daniel@constexpr.org> - 1.4-1
- Bump version to 1.4 (new upstream release):
- Fixed issues with the progress bar in sandbox environments
- Fixed extracting very large installers with 32-bit innoextract builds
- Improved handling
- The --list command-line option can now combined with --test or --extract
- The --version command-line option can now be modified with --quiet
  or --silent
- Added support for preserving timestamps of extracted files
  (enabled by default)
- Added a --timestamps (-T) command-line options to control or disable
  file timestamps
- Added an --output-dir (-d) command-line option to control where files
  are extracted
- Various bug fixes and tweaks

* Tue Jul 03 2012 Daniel Scharrer <daniel@constexpr.org> - 1.3-1
- bump version to 1.3:
- Respect --quiet and --silent for multi-file installers
- Compile in C++11 mode if supported
- Warn about unsupported setup data versions
- Add support for Inno Setup 5.5.0 installers

* Sun Mar 25 2012 Daniel Scharrer <daniel@constexpr.org> - 1.2-1
- created package
