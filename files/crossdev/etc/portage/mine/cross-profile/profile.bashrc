
# We a cross-compiling from Linux - don't try to use *BSD tools
USERLAND="GNU"

post_src_install() {
	
	[[ -d "${D}" ]] || return 0
	
	# &^%*&^#$libtool hardcoded absolute library paths - fix them
	# many thanks to http://metastatic.org/text/libtool.html
	echo "Fixing library path in .la files..."
	find "${D}" -name '*.la' -exec sed -i "s:'/usr/lib:'${ROOT}usr/lib:g" {} \;
	find "${D}" -name '*.la' -exec sed -i "s:'/lib:'${ROOT}lib:g" {} \;
	
	[[ ${E_MACHINE} == "" ]] && return 0
	cmdline=""
	for EM in $E_MACHINE; do
		cmdline+=" -e ^${EM}[[:space:]]";
	done
	output="$( cd ${D} && scanelf -RmyBF%a . | grep -v ${cmdline} )"
	[[ $output != "" ]] && { echo; echo "* Wrong EM_TYPE. Expected ${E_MACHINE}"; echo -e "${output}"; echo; exit 1; }
	
}

# We don't run this on the assumption that when you're
# emerging binary packages, it's into a runtime ROOT
# rather than build development ROOT.  The former doesn't
# want hacking while the latter does.
if [[ $EBUILD_PHASE == "postinst" ]]; then
	[[ $SYSROOT == $ROOT ]] && cross-fix-root ${CHOST}
fi

function rename_func() {
	local old="$1"
	local new="$2"
	eval "$(echo "$new()"; declare -f "$old" | tail -n +2)"
}

if [ "$PN" = "libarchive" ] ; then
	LDFLAGS="$LDFLAGS -static-libgcc"
	rename_func econf orig_econf
	econf() {
		local args=( )
		for arg in "$@" ; do
			case "$arg" in
				--enable-bsdtar=shared) continue ;;
				--enable-bsdcpio*) continue ;;
				*) args+=( "$arg" )
			esac
		done
		sed -i 's:\-lz:${ROOT}usr/lib/libz.a:g' "${S}/configure"
		orig_econf "${args[@]}" \
			--without-xml2 --without-expat --without-openssl \
			--disable-acl --disable-xattr \
			--disable-bsdcpio --enable-bsdtar=static 
	}
	LDFLAGS="$LDFLAGS -Wl,-z,origin -Wl,-rpath,\\\$\$ORIGIN"
fi

if [ "$PN" = "libsdl" ] ; then
	CC="${CC:-$CHOST-gcc} -static-libgcc" # I hate libtool
	rename_func econf orig_econf
	econf() {
		local args=( )
		for arg in "$@" ; do
			case "$arg" in
				--enable-cdrom) continue ;;
				--enable-threads) continue ;;
				--enable-timers) continue ;;
				--enable-file) continue ;;
				--enable-cpuinfo) continue ;;
				*) args+=( "$arg" )
			esac
		done
		orig_econf "${args[@]}" \
			--disable-cdrom --disable-threads --disable-timers --disable-file --disable-cpuinfo
	}
fi

if [ "$PN" = "libsdl2" ] ; then
	CC="${CC:-$CHOST-gcc} -static-libgcc" # I hate libtool
	strip-flags() {
		true
	}
	rename_func econf orig_econf
	econf() {
		local args=( )
		for arg in "$@" ; do
			case "$CHOST" in
				*mingw*)
				case "$arg" in
					--disable-directx) continue ;;
				esac
			esac
			case "$arg" in
				--enable-timers) continue ;;
				--enable-file) continue ;;
				--enable-filesystem) continue ;;
				--enable-cpuinfo) continue ;;
				--enable-render) continue ;;
				--enable-atomic) continue ;;
				--enable-power) continue ;;
				--disable-alsa-shared) continue ;;
				--disable-esd-shared) continue ;;
				--disable-pulseaudio-shared) continue ;;
				--disable-arts-shared) continue ;;
				--disable-nas-shared) continue ;;
				--disable-sndio-shared) continue ;;
				--disable-x11-shared) continue ;;
				--disable-directfb-shared) continue ;;
				--disable-fusionsound-shared) continue ;;
				--disable-wayland-shared) continue ;;
				--disable-mir-shared) continue ;;
				*) args+=( "$arg" )
			esac
		done
		CFLAGS="$CFLAGS -std=gnu99" orig_econf "${args[@]}" \
			--disable-timers \
			--disable-file \
			--disable-cpuinfo \
			--disable-render \
			--disable-atomic \
			--disable-power \
			--enable-alsa-shared \
			--enable-esd-shared \
			--enable-pulseaudio-shared \
			--enable-arts-shared \
			--enable-nas-shared \
			--enable-sndio-shared \
			--enable-wayland-shared \
			--enable-mir-shared \
			--enable-x11-shared \
			--enable-directfb-shared \
			--enable-fusionsound-shared
		# --disable-filesystem breaks the build :(
	}
	if [[ $EBUILD_PHASE == "prepare" ]]; then
		rename_func eautoreconf orig_eautoreconf
		eautoreconf() {
			pushd "${S}" > /dev/null
			epatch_user
			popd > /dev/null
			orig_eautoreconf "$@"
		}
	fi
	post_src_prepare() {
		# SDL patches their own copy of the libtool sources to adjust the dll name on windows
		# this change gets lost when gentoo regenerates the files
		echo 'Fixing Win32 soname...'
		pushd "${S}" > /dev/null
		patch -p0 < /etc/portage/mine/cross-patches/libsdl2-win32-soname.patch
		popd > /dev/null
	}
fi

if [ "$PN" = "freetype" ] ; then
	post_src_prepare() {
		disable_option FT_CONFIG_OPTION_USE_LZW
		disable_option FT_CONFIG_OPTION_USE_ZLIB
		enable_option  FT_CONFIG_OPTION_DISABLE_STREAM_SUPPORT
		disable_option FT_CONFIG_OPTION_MAC_FONTS
		disable_option FT_CONFIG_OPTION_INCREMENTAL
		disable_option TT_CONFIG_OPTION_EMBEDDED_BITMAPS
		disable_option TT_CONFIG_OPTION_SFNT_NAMES
	}
fi

if [ "$PN" = "libepoxy" ] ; then
	rename_func econf orig_econf
	econf() {
		orig_econf "$@" \
			--enable-static
	}
fi

if [ "$PN" = "openal" ] ; then
	LDFLAGS="$LDFLAGS -static-libgcc"
fi

if [ "$PN" = "zlib" ] ; then
	LDFLAGS="$LDFLAGS -static-libgcc"
fi

if [ "$PN" = "libX11" ] || [ "$PN" = "libXext" ] || [ "$PN" = "libXxf86vm" ] ; then
	LDFLAGS="$LDFLAGS -static-libgcc"
	rename_func econf orig_econf
	econf() {
		echo Hi!
		orig_econf "$@" \
			--enable-malloc0returnsnull
	}
fi

if [ "$PN" = "mesa" ] || [ "$PN" = "expat" ] || [ "$PN" = "libXdamage" ] || [ "$PN" = "libXfixes" ] || [ "$PN" = "libxcb" ] || [ "$PN" = "libdrm" ] ; then
	LDFLAGS="$LDFLAGS -static-libgcc"
fi
