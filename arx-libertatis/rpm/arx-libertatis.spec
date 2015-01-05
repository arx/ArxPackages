#
# spec file for package arx-libertatis, arx, arxunpak, arxsavetool and arxcrashreporter
#
# Copyright (c) 2012-2014 Daniel Scharrer <daniel@constexpr.org>
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
Version:        1.1.2
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
BuildRequires:  boost-devel >= 1.48
BuildRequires:  glm-devel >= 0.9.2.7
BuildRequires:  zlib-devel
BuildRequires:  pkgconfig(sdl2) >= 2.0.0
%if 0%{?suse_version}
BuildRequires:  freetype2-devel >= 2.3.0
%else
BuildRequires:  freetype-devel >= 2.3.0
%endif
BuildRequires:  openal-devel
BuildRequires:  pkgconfig(gl)
BuildRequires:  glew-devel >= 1.5.2
BuildRequires:  pkgconfig(QtCore) >= 4.7
BuildRequires:  pkgconfig(QtGui) >= 4.7
BuildRequires:  pkgconfig(QtNetwork) >= 4.7
BuildRequires:  xz
%if 0%{?suse_version}
BuildRequires:  update-desktop-files
Recommends:     arxcrashreporter
Suggests:       arxunpak
Suggests:       arxsavetool
Suggests:       innoextract
%else
# TODO Fedora doesn't know these tags yet as of Fedora 19
# Drop the hard dependency once we have a sane way to specify the optional one
Requires:       arxcrashreporter
%endif
Summary:        Cross-platform port of Arx Fatalis, a first-person role-playing game
Group:          Amusements/Games/RPG
%description
Cross-platform port of Arx Fatalis, a first-person role-playing game.
This package only includes the game executable - you will also need
the data files from the original game.

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
	-DINSTALL_DATADIR="%{_datadir}/arx" \
	-DWITH_QT=4 \
	-DWITH_SDL=2 \
	-DUNITY_BUILD=ON
make

%install
make DESTDIR=%{buildroot} install
%if 0%{?suse_version}
%suse_update_desktop_file %name
%endif

%files
%defattr(-,root,root)
%{_bindir}/arx
%{_bindir}/arx-install-data
%{_datadir}/arx
%{_datadir}/pixmaps/arx-libertatis.png
%{_datadir}/applications/arx-libertatis.desktop
%{_mandir}/man1/arx-install-data.1*
%{_mandir}/man6/arx.6*
%doc README.md AUTHORS CHANGELOG COPYING* LICENSE

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
* Thu Oct 17 2013 Daniel Scharrer <daniel@constexpr.org> 1.1.2
- Bump version to 1.1.2 (new upstream release):
- Fixed a crash when hovering over map markers after the window was resized
* Wed Jul 17 2013 Daniel Scharrer <daniel@constexpr.org> 1.1.1
- Bump version to 1.1.1 (new upstream release):
- Fixed map marker labels not being saved
* Sun Jul 14 2013 Daniel Scharrer <daniel@constexpr.org> 1.1
- Bump version to 1.1 (new upstream release):
- Added support for multiple simultaneous data directories
- Improved error messages for missing data files
- Added an error dialog if the user directory could not be created
- Enabled up to 8xMSAA (if supported) with the SDL/OpenGL backend
- Added universal GUI+CLI data install script to packages
- Translated the .desktop file to French, German and Russian
- Fixed Am Shaegar accelerating too much during slow frames
- Increased jump distance to fix some jumps that have become too hard
- Replaced DevIL with stb_image for image loading
- Fixed improper handling of set-but-empty $XDG_* variables
- Merged remaining fixes from Nuky's arx-fatalis-fixed
- Fixed minimap showing a smaller area on higher resolutions
- Removed dependency on Boost.Program_options - Boost is now only needed
  at build-time. We tried to keep the same command-line argument syntax
  but there might be slight changes in corner cases.
- Changed to always create a user/config directory in the user's in home
  directory unless explicitly changed with the --user-dir and/or --config-dir
  options or registry keys. Previously, if no data and user directories
  were found, the current working directory was used as the user directory.
- Added /opt as a system data directory prefix (besides $XDG_DATA_DIRS)
- Added arx as a system data directory suffix (besides games/arx)
- Added the executable directory as a system data directory
- Enabled C++11 mode for GNU-compatible compilers, if supported
- Various bug fixes and tweaks
* Tue Jul 31 2012 Daniel Scharrer <daniel@constexpr.org> 1.0.3
- Bump version to 1.0.3:
- Fixed minor rendering glitches
- Fixed missing speech in cinematics for the Russian and Italian versions
- Fixed missing ambient sound effects
- Include attribute modifiers when calculating the effective object knowledge
  and projectile skills
- Savegames can now be deleted from the save and load menus
* Thu Jun 14 2012 Daniel Scharrer <daniel@constexpr.org> 1.0.2
- bump version to 1.0.2:
- Fixed various crashes
- Fixed disappearing items when sorting the inventory
- Fixed minor rendering and input bugs
- Fixed spanish version
* Sun Apr 22 2012 Daniel Scharrer <daniel@constexpr.org> 1.0.1
- bump version to 1.0.1:
- Fixed garbled text rendering in the Russian version (upstream bug #226)
- Fixed a crash in the critical error dialog on some Linux systems
  (upstream crash report #229)
- Loading files from the 'graph' and 'misc' directories is now case-insensitive
* Mon Mar 26 2012 Daniel Scharrer <daniel@constexpr.org> 1.0
- created package
