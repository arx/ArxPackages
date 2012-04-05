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
URL:            http://arx-libertatis.org/
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
BuildRequires:  libdevil-devel >= 1.7
%else
BuildRequires:  DevIL-devel >= 1.7
%endif
BuildRequires:  zlib-devel
BuildRequires:  SDL-devel >= 1.2
%if 0%{?suse_version}
BuildRequires:  freetype2-devel
%else
BuildRequires:  freetype-devel
%endif
BuildRequires:  openal-devel
BuildRequires:  pkgconfig(gl)
BuildRequires:  glew-devel >= 1.5.2
BuildRequires:  pkgconfig(QtCore)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtNetwork)
BuildRequires:  xz
%if 0%{?suse_version}
BuildRequires:  update-desktop-files
%endif
Requires:       arx
Requires:       arxcrashreporter
%description
Cross-platform port of Arx Fatalis, a first-person role-playing game.
This package only includes the game executable - you will also need
the data files from the original game.

%package -n arx
Summary:        Cross-platform port of Arx Fatalis, a first-person role-playing game
Group:          Amusements/Games/RPG
%description -n arx
Cross-platform port of Arx Fatalis, a first-person role-playing game.
This package only includes the game executable - you will also need
the data files from the original game.

Besides the data files, this is all that is needed to run the game, but installing
the main arx-libertatis package to get the arxcrashreporter is recommended.

%package -n arxunpak
Summary:        Tool to extract the Arx Fatalis .pak files containing the game assets
Group:          Productivity/Archiving/Compression
%description -n arxunpak
Tool to extract the .pak files containing the game assets of the original Arx Fatalis.

This is not required to run Arx Libertatis but can be useful for development.

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
	-DCMAKE_INSTALL_DATAROOTDIR="%{_datadir}" \
	-DCMAKE_INSTALL_MANDIR="%{_mandir}" \
	-DCMAKE_INSTALL_BINDIR="%{_bindir}" \
	-DCMAKE_INSTALL_LIBEXECDIR="%{_libexecdir}" \
	-DUNITY_BUILD=ON
make

%install
make DESTDIR=%{buildroot} install
%if 0%{?suse_version}
%suse_update_desktop_file %name
%endif

%if !0%{?suse_version}
%files
%endif

%files -n arx
%defattr(-,root,root)
%{_bindir}/arx
%doc README.md AUTHORS CHANGELOG ARX_PUBLIC_LICENSE.txt
%{_datadir}/pixmaps/arx-libertatis.png
%{_datadir}/applications/arx-libertatis.desktop
%{_mandir}/man6/arx.6*

%files -n arxunpak
%defattr(-,root,root)
%{_bindir}/arxunpak
%{_mandir}/man1/arxunpak.1*

%files -n arxsavetool
%defattr(-,root,root)
%{_bindir}/arxsavetool
%{_mandir}/man1/arxsavetool.1*

%files -n arxcrashreporter
%defattr(-,root,root)
%{_libexecdir}/arxcrashreporter

%post
%desktop_database_post
echo "This package only installs the game binary."
echo "You will also need the demo or full game data."
echo "See http://wiki.arx-libertatis.org/Getting_the_game_data for more information."

%postun
%desktop_database_postun

%changelog
* Sun Mar 26 2011 Daniel Scharrer <daniel@constexpr.org> 1.0
- created package