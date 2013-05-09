
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
