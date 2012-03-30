#
# spec file for package innoextract
#
# Copyright (c) 2012 Daniel Scharrer <daniel@constexpr.org>
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
Version:        1.1
Release:        0
License:        Zlib
Summary:        A tool to extract installers created by Inno Setup
Url:            http://innoextract.constexpr.org/
Group:          Productivity/Archiving/Compression
Source:         %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
%if 0%{?suse_version}
BuildRequires:  c++_compiler
%else
BuildRequires:  gcc-c++
%endif
BuildRequires:  cmake >= 2.8
BuildRequires:  boost-devel
BuildRequires:  pkgconfig(liblzma)

%description
Inno Setup is a tool to create installers for Microsoft Windows
applications. Inno Extracts allows to extract such installers under
non-windows systems without running the actual installer using wine.
Inno Extract currently supports installers created by
Inno Setup 1.2.10 to 5.4.3.

%prep
%setup -q

%build
cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_CXX_FLAGS="$RPM_OPT_FLAGS" -DMAN_DIR=%{_mandir}
make

%install
make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
%doc README.md CHANGELOG
%doc %{_mandir}/man1/innoextract.1*
%{_bindir}/innoextract

%changelog
* Sun Mar 25 2011 Daniel Scharrer <daniel@constexpr.org>
- created package
