. /etc/portage/mine/cross-profile/profile.bashrc

# Somehow this ended up as "Winnt Interix" which messed up cmake-utils.eclass
export KERNEL="Winnt"

fake_cmake() {
	
	local toolchain_file=${BUILD_DIR}/gentoo_toolchain.cmake
	[ -f "$toolchain_file" ] || return 1
	cat >> ${toolchain_file} <<- _EOF_
		SET (CMAKE_RC_COMPILER ${CHOST}-windres)
	_EOF_
	
	cmake "$@" -DHOST=$CHOST
}

CMAKE_BINARY="fake_cmake"
