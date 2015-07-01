
set(root "${CMAKE_FIND_ROOT_PATH}")
set(path "$ENV{PATH}")
string(REPLACE "${compilerdir}/:" "" path "${path}")
string(REPLACE "${compilerdir}" "/dev/null" path "${path}")
set(ENV{PATH} "${compilerdir}/:$ENV{PATH}")

# CMake uses 'link' to link static and dynamic libraries - make sure it can be found
set(_wrap_linker "link")
# TODO A better solution should be to set CMAKE_LINKER,
# but for some reason CMake ends up clearing that var and using the empty string.
#set(CMAKE_LINKER "${_msvc_dir}/link")

get_filename_component(scriptdir "${CMAKE_CURRENT_LIST_FILE}" PATH)

foreach(var IN ITEMS CMAKE_C_COMPILER CMAKE_CXX_COMPILER _wrap_linker)
	set(compiler "${${var}}")
	get_filename_component(name "${compiler}" NAME)
	set(wrapper "${compilerdir}/${name}")
	configure_file("${scriptdir}/compiler-wrapper" "${wrapper}" ESCAPE_QUOTES @ONLY)
	set(${var} "${wrapper}")
	unset(wrapper)
	unset(name)
	unset(compiler)
endforeach()

file(WRITE "${rootdir}/arch" "${CMAKE_CXX_LIBRARY_ARCHTECTURE}")
file(WRITE "${rootdir}/paths" "${root}\n")
foreach(path IN LISTS CMAKE_SYSTEM_PREFIX_PATH CMAKE_PREFIX_PATH)
	file(APPEND "${rootdir}/paths" "${root}${path}\n")
endforeach()
foreach(path IN LISTS CMAKE_SYSTEM_LIBRARY_PATH CMAKE_LIBRARY_PATH)
	file(APPEND "${rootdir}/paths" "${root}${path}\n")
endforeach()

unset(scriptdir)
unset(_wrap_linker)
unset(path)
unset(root)
unset(rootdir)
unset(compilerdir)
unset(depsdir)
