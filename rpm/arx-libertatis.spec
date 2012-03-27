#
# spec file for package arx-libertatis, arx, arxunpak, arxsavetool and arxcrashreporter
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

# Please submit bugfixes or comments via http://bugs.arx-libertatis.org/
#

Name:           arx-libertatis
Version:        1.0_rc4
Release:        0
License:        GPL-3.0+
Summary:        Cross-platform port of Arx Fatalis, a first-person role-playing game
Url:            http://arx-libertatis.org/
Group:          Amusements/Games/RPG
Source:         %{name}-%{version}.tar.xz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
%if 0%{?suse_version}
BuildRequires:  c++_compiler
%else
BuildRequires:  gcc-c++
%endif
BuildRequires:  cmake >= 2.8
BuildRequires:  boost-devel >= 1.39
%if 0%{?mandriva_version}
BuildRequires:  libdevil-devel
%else
BuildRequires:  DevIL-devel
%endif
BuildRequires:  zlib-devel
BuildRequires:  SDL-devel
%if 0%{?suse_version}
BuildRequires:  freetype2-devel
%else
BuildRequires:  freetype-devel
%endif
BuildRequires:  openal-devel
BuildRequires:  pkgconfig(gl)
BuildRequires:  glew-devel
BuildRequires:  pkgconfig(QtCore)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtNetwork)
BuildRequires:  xz
Requires:       arx
Requires:       arxcrashreporter
%description
Cross-platform port of Arx Fatalis, a first-person role-playing game.
This package only includes the game executable - you will also need
the data files from the original game.

%package -n arx
Summary:        The main arx-libertatis binary
Group:          Amusements/Games/RPG
%description -n arx
The main arx-libertatis binary. Besides the data files, this is all that is needed
to run the game, but installing the main arx-libertatis package to get
the arxcrashreporter is recommended.

%package -n arxunpak
Summary:        Tool to extract the Arx Fatalis .pak files containing the game assets
Group:          Productivity/Archiving/Compression
%description -n arxunpak
Tool to extract the Arx Fatalis .pak files containing the game assets.

%package -n arxsavetool
Summary:        Tool to inspect and modify Arx Libertatis save files
Group:          Development/Tools/Other
%description -n arxsavetool
Tool to inspect and modify Arx Libertatis save files. Allows to extract
individual files from save file containers and re-pack them. Also allows
listing the information contained in save files and fixing some errors caused
by broken versions of the game.

%package -n arxcrashreporter
Summary:        Arx Libertatis crash reporter
Group:          Development/Tools/Debuggers
Requires:       gdb
%description -n arxcrashreporter
A GUI tool to report detailed information to https://bugs.arx-libertatis.org/
if Arx Libertatis crashes.

%prep
%setup -q

%build
cmake . -DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_CXX_FLAGS="$RPM_OPT_FLAGS" \
	-DUNITY_BUILD=ON
make

%install
make DESTDIR=%{buildroot} install

%files

%files -n arx
%defattr(-,root,root)
%{_bindir}/arx
%doc README.md AUTHORS CHANGELOG
%{_datadir}/pixmaps/arx-libertatis.png
%{_datadir}/applications/arx-libertatis.desktop

%files -n arxunpak
%defattr(-,root,root)
%{_bindir}/arxunpak

%files -n arxsavetool
%defattr(-,root,root)
%{_bindir}/arxsavetool

%files -n arxcrashreporter
%defattr(-,root,root)
%{_bindir}/arxcrashreporter

%post
echo "This package only installs the game binary."
echo "You will also need the demo or full game data."

%changelog
* Sun Mar 26 2011 daniel@constexpr.org
- created package
