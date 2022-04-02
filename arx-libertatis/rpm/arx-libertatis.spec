#
# spec file for arx-libertatis
#
# Copyright (c) 2012-2019 Daniel Scharrer <daniel@constexpr.org>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.arx-libertatis.org/
#

# The blender plugin requires python 3
%define __python %{__python3}

%define have_blender 1
%if 0%{?suse_version} > 1500
%ifarch i586
%define have_blender 0
%endif
%endif
%if 0%{?mageia} == 6 || 0%{?sle_version} == 150300 || 0%{?sle_version} == 150400
%define have_blender 0
%endif

Name:           arx-libertatis
Version:        1.2
Release:        1%{?dist}
%if 0%{?suse_version}
License:        GPL-3.0+
%else
License:        GPLv3+
%endif
Summary:        Cross-platform port of Arx Fatalis, a first-person role-playing game
URL:            https://arx-libertatis.org/
%if 0%{?suse_version}
Group:          Amusements/Games/RPG
%else
Group:          Amusements/Games
%endif
Source:         https://arx-libertatis.org/files/%{name}-%{version}.tar.xz
<? if($bin): ?>
%global         privatelibs libSDL2.*|libopenal
%global         __provides_exclude ^(%{privatelibs})\\.so
%global         __requires_exclude ^(%{privatelibs})\\.so
<? else: ?>
%if 0%{?suse_version}
BuildRequires:  c++_compiler
%else
BuildRequires:  gcc-c++
%endif
BuildRequires:  cmake
BuildRequires:  boost-devel >= 1.48
BuildRequires:  glm-devel >= 0.9.5.0
BuildRequires:  pkgconfig(zlib)
BuildRequires:  pkgconfig(sdl2) >= 2.0.0
BuildRequires:  pkgconfig(freetype2) >= 2.3.0
BuildRequires:  pkgconfig(openal)
BuildRequires:  pkgconfig(epoxy) >= 1.2
<? endif ?>
BuildRequires:  pkgconfig(Qt5Core) >= 5.0.0
BuildRequires:  pkgconfig(Qt5Concurrent) >= 5.0.0
BuildRequires:  pkgconfig(Qt5Gui) >= 5.0.0
BuildRequires:  pkgconfig(Qt5Widgets) >= 5.0.0
BuildRequires:  pkgconfig(libcurl) >= 7.20.0
BuildRequires:  xz
%if 0%{?suse_version}
BuildRequires:  update-desktop-files
%endif
%if 0%{?have_blender}
BuildRequires:  blender-rpm-macros
BuildRequires:  blender
%endif
Recommends:     arxcrashreporter
Recommends:     arx-libertatis-tools
Conflicts:      arxcrashreporter < %{version}
Conflicts:      arxcrashreporter > %{version}-9999
Suggests:       innoextract
%description
Cross-platform port of Arx Fatalis, a first-person role-playing game.
This package only includes the game executable - you will also need
the data files from the original game.

%package tools
Summary:        Arx Libertatis tools
%if 0%{?suse_version}
Group:          Productivity/Archiving/Compression
%else
Group:          Applications/Archiving
%endif
Provides:       arxsavetool = %{version}
Provides:       arxunpak = %{version}
Conflicts:      arxsavetool < %{version}
Conflicts:      arxunpak < %{version}
Obsoletes:      arxsavetool < %{version}
Obsoletes:      arxunpak < %{version}
%description tools
Tools to work with Arx Fatalis data:

arxsavetool can inspect and extract .sav files containing saved game states.

arxunpak can extract the .pak files containing the game assets of the original Arx Fatalis.

This is not required to run Arx Libertatis but can be useful for development.

%package -n arxcrashreporter
Summary:        Arx Libertatis crash reporter
%if 0%{?suse_version}
Group:          Development/Tools/Debuggers
%else
Group:          Development/Tools
%endif
Requires:       gdb
%description -n arxcrashreporter
A GUI tool to report detailed information to https://bugs.arx-libertatis.org/
if Arx Libertatis crashes.

%package -n libArxIO0
Summary:        Arx compression helper library
%if 0%{?suse_version}
Group:          System/Libraries
%else
Group:          System Environment/Libraries
%endif
%description -n libArxIO0
Arx Fatalis compression helper library used by the Blender addon.

%package -n libArxIO-devel
Summary:        Arx compression helper library (development files)
%if 0%{?suse_version}
Group:          Development/Libraries/C and C++
%else
Group:          Development/Libraries
%endif
Requires:       libArxIO0 = %{version}-%{release}
%description -n libArxIO-devel
Arx Fatalis compression helper library used by the Blender addon (development files).

%if 0%{?have_blender}
%package -n arx-blender-addon
Summary:        Arx Libertatis Blender addon
%if 0%{?suse_version}
Group:          Productivity/Graphics/3D Editors
%else
Group:          Applications/Editors
%endif
Requires:       libArxIO0 >= %{version}-%{release}
Requires:       blender
Enhances:       blender
BuildArch:      noarch
%description -n arx-blender-addon
Blender addon to edit Arx Fatalis data files.
%endif

%prep
%setup -q

%build
<? if($bin): ?>
# select binary architecture
%ifarch x86_64
mv bin/amd64/* bin/
%else
mv bin/i686/* bin/
%endif
rm -r bin/i686
rm -r bin/amd64
# remove unwanted files
rm bin/innoextract
rm license/innoextract.*
rm bin/bsdtar
rm license/libarchive.*
rm bin/arxsavetool
rm bin/arxunpak
rm data/README
<? else: ?>
%if 0%{?have_blender}
%cmake \
	-DCMAKE_INSTALL_LIBEXECDIR="%{_libexecdir}" \
	-DINSTALL_BLENDER_PLUGINDIR="%{blender_addons}/arx" \
	-DINSTALL_DATADIR="%{_datadir}/arx" \
	-DRUNTIME_DATADIR=""
%else
%cmake \
	-DCMAKE_INSTALL_LIBEXECDIR="%{_libexecdir}" \
	-DINSTALL_BLENDER_PLUGIN=OFF \
	-DBUILD_IO_LIBRARY=ON \
	-DINSTALL_DATADIR="%{_datadir}/arx" \
	-DRUNTIME_DATADIR=""
%endif
%if 0%{?sle_version} >= 150100 || 0%{?mageia} >= 8 || 0%{?fedora_version} >= 33
%cmake_build
%else
%if 0%{?suse_version}
make %{?_smp_mflags}
%else
%make_build
%endif
%endif
<? endif ?>

%install
<? if($bin): ?>
# blender plugin
install -d "%{buildroot}/%{_libdir}"
mv bin/libArxIO.so* "%{buildroot}/%{_libdir}/"
install -d "%{buildroot}/%{_includedir}"
mv bin/ArxIO.h "%{buildroot}/%{_includedir}/"
%if 0%{?have_blender}
install -d "%{buildroot}/%{blender_addons}"
mv plugins/blender/arx_addon "%{buildroot}/%{blender_addons}/arx"
%endif
# tools
install -d "%{buildroot}/%{_bindir}"
ln -rs "%{buildroot}/%{_libexecdir}/arxtool" "%{buildroot}/%{_bindir}/arxunpak"
ln -rs "%{buildroot}/%{_libexecdir}/arxtool" "%{buildroot}/%{_bindir}/arxsavetool"
mv bin/arx-install-data "%{buildroot}/%{_bindir}/"
install -d "%{buildroot}/%{_libexecdir}"
mv bin/arxtool "%{buildroot}/%{_libexecdir}/"
mv bin/arxcrashreporter "%{buildroot}/%{_libexecdir}/"
# main binary and support libraries
install -d "%{buildroot}/%{_libexecdir}/arx"
mv bin/* "%{buildroot}/%{_libexecdir}/arx/"
ln -rs "%{buildroot}/%{_libexecdir}/arx/arx" "%{buildroot}/%{_bindir}/arx"
# man pages
install -d "%{buildroot}/%{_mandir}/man1"
mv doc/*.1 "%{buildroot}/%{_mandir}/man1/"
install -d "%{buildroot}/%{_mandir}/man6"
mv doc/*.6 "%{buildroot}/%{_mandir}/man6/"
# data
install -d "%{buildroot}/%{_datadir}/arx"
mv data/* "%{buildroot}/%{_datadir}/arx/"
# icons
install -d "%{buildroot}/%{_datadir}/icons/hicolor/16x16/apps"
mv arx-libertatis_16.png "%{buildroot}/%{_datadir}/icons/hicolor/16x16/apps/arx-libertatis.png"
install -d "%{buildroot}/%{_datadir}/icons/hicolor/22x22/apps"
mv arx-libertatis_22.png "%{buildroot}/%{_datadir}/icons/hicolor/22x22/apps/arx-libertatis.png"
install -d "%{buildroot}/%{_datadir}/icons/hicolor/24x24/apps"
mv arx-libertatis_24.png "%{buildroot}/%{_datadir}/icons/hicolor/24x24/apps/arx-libertatis.png"
install -d "%{buildroot}/%{_datadir}/icons/hicolor/32x32/apps"
mv arx-libertatis_32.png "%{buildroot}/%{_datadir}/icons/hicolor/32x32/apps/arx-libertatis.png"
install -d "%{buildroot}/%{_datadir}/icons/hicolor/128x128/apps"
mv arx-libertatis.png "%{buildroot}/%{_datadir}/icons/hicolor/128x128/apps/arx-libertatis.png"
install -d "%{buildroot}/%{_datadir}/applications"
mv arx-libertatis.desktop "%{buildroot}/%{_datadir}/applications/"
<? else: ?>
%if 0%{?suse_version} || 0%{?mageia} >= 8 || 0%{?fedora_version} >= 33
%cmake_install
%else
%if 0%{?mageia}
%make_install -C build
%else
%make_install
%endif
%endif
<? endif ?>
%if 0%{?suse_version}
%suse_update_desktop_file %name
%endif

%files
%defattr(-,root,root)
<? $lincense_files = $bin ? 'license/*' : 'LICENSE* COPYING*' ?>
%if 0%{?suse_version}
%doc <?= $lincense_files . "\n" ?>
%else
%license <?= $lincense_files . "\n" ?>
%endif
%doc README* AUTHORS CHANGELOG VERSION
%{_bindir}/arx
%{_bindir}/arx-install-data
%{_datadir}/arx
%dir %{_datadir}/icons/hicolor
%dir %{_datadir}/icons/hicolor/*
%dir %{_datadir}/icons/hicolor/*/apps
%{_datadir}/icons/hicolor/*/apps/arx-libertatis.png
%{_datadir}/applications/arx-libertatis.desktop
%{_mandir}/man1/arx-install-data.1*
%{_mandir}/man6/arx.6*
<? if($bin): ?>
%dir %{_libexecdir}/arx
%{_libexecdir}/arx/arx
%{_libexecdir}/arx/libSDL2-2.0.so.*
%{_libexecdir}/arx/libopenal.so.*
<? endif ?>

%files tools
%defattr(-,root,root)
%{_bindir}/arxunpak
%{_bindir}/arxsavetool
%{_mandir}/man1/arxunpak.1*
%{_mandir}/man1/arxsavetool.1*
%{_libexecdir}/arxtool

%files -n arxcrashreporter
%defattr(-,root,root)
%{_libexecdir}/arxcrashreporter

%files -n libArxIO0
%defattr(-,root,root)
%{_libdir}/libArxIO.so.*

%files -n libArxIO-devel
%defattr(-,root,root)
%{_includedir}/ArxIO.h
%{_libdir}/libArxIO.so

%if 0%{?have_blender}
%files -n arx-blender-addon
%defattr(-,root,root)
%dir %{blender_addons}
%{blender_addons}
%endif

%post
%desktop_database_post
echo "This package only installs the game binary."
echo "You will also need the demo or full game data."
echo "See https://arx.vg/data for more information."

%post -n libArxIO0 -p /sbin/ldconfig

%postun
%desktop_database_postun

%postun -n libArxIO0 -p /sbin/ldconfig

%changelog
* Wed Jul 14 2021 Daniel Scharrer <daniel@constexpr.org> - 1.2-1
- Bump version to 1.2 (new upstream release):
- This release brings improved rune recognition when casting spells, as well as a new bow aim mode. Support for high resolutions and wide monitors is enhanced with configurable HUD and player book scaling. The text and audio language can now be changed in the menu. Further, item physics have been fixed and item dragging has been refined. On top of that, this release adds a console to execute arbitrary script commands.

* Thu Oct 17 2013 Daniel Scharrer <daniel@constexpr.org> - 1.1.2-1
- Bump version to 1.1.2 (new upstream release):
- Fixed a crash when hovering over map markers after the window was resized

* Wed Jul 17 2013 Daniel Scharrer <daniel@constexpr.org> - 1.1.1-1
- Bump version to 1.1.1 (new upstream release):
- Fixed map marker labels not being saved

* Sun Jul 14 2013 Daniel Scharrer <daniel@constexpr.org> - 1.1-1
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

* Tue Jul 31 2012 Daniel Scharrer <daniel@constexpr.org> - 1.0.3-1
- Bump version to 1.0.3:
- Fixed minor rendering glitches
- Fixed missing speech in cinematics for the Russian and Italian versions
- Fixed missing ambient sound effects
- Include attribute modifiers when calculating the effective object knowledge
  and projectile skills
- Savegames can now be deleted from the save and load menus

* Thu Jun 14 2012 Daniel Scharrer <daniel@constexpr.org> - 1.0.2-1
- bump version to 1.0.2:
- Fixed various crashes
- Fixed disappearing items when sorting the inventory
- Fixed minor rendering and input bugs
- Fixed spanish version

* Sun Apr 22 2012 Daniel Scharrer <daniel@constexpr.org> - 1.0.1-1
- bump version to 1.0.1:
- Fixed garbled text rendering in the Russian version (upstream bug #226)
- Fixed a crash in the critical error dialog on some Linux systems
  (upstream crash report #229)
- Loading files from the 'graph' and 'misc' directories is now case-insensitive

* Mon Mar 26 2012 Daniel Scharrer <daniel@constexpr.org> - 1.0-1
- created package
