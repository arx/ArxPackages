
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
	rename_func econf orig_econf
	econf() {
		orig_econf "$@" \
			--without-xml2 --without-expat --without-openssl \
			--disable-acl --disable-xattr \
			--disable-bsdcpio --enable-bsdtar=static 
	}
	LDFLAGS="$LDFLAGS -Wl,-z,origin -Wl,-rpath,\\\$\$ORIGIN"
fi

if [ "$PN" = "libsdl" ] ; then
	rename_func econf orig_econf
	econf() {
		orig_econf "$@" \
			--disable-cdrom --disable-threads --disable-timers --disable-file --disable-cpuinfo
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
