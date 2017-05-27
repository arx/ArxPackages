
macro(add_definitions)
endmacro()

if(DEFINED CMAKE_TOOLCHAIN_FILE)
	include(${CMAKE_TOOLCHAIN_FILE})
endif()

set(CMAKE_INSTALL_DATAROOTDIR "share" CACHE STRING "")
set(CMAKE_INSTALL_LIBEXECDIR "libexec" CACHE STRING "")
set(INSTALL_DATADIR "${CMAKE_INSTALL_DATAROOTDIR}" CACHE STRING "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(type ${TYPE})
set(target ${TARGET})
set(logfile ${LOGFILE})

if(type STREQUAL "bin")
	
	find_program(path "${target}")
	
	set(destination ${CMAKE_INSTALL_LIBEXECDIR})
	
elseif(type STREQUAL "lib")
	
	find_library(path "${target}")
	
	set(destination ${CMAKE_INSTALL_LIBEXECDIR})
	
elseif(type STREQUAL "share")
	
	unset(path)
	set(prefixes ${CMAKE_PREFIX_PATH} ${CMAKE_SYSTEM_PREFIX_PATH} "/usr" "")
	foreach(prefix IN LISTS prefixes)
		set(candidate "${CMAKE_FIND_ROOT_PATH}${prefix}/share/${target}")
		if(EXISTS "${candidate}")
			set(path ${candidate})
			break()
		endif()
	endforeach()
	
	set(destination ${INSTALL_DATADIR})
	
else()
	
	message(FATAL_ERROR "Unknown type: ${type}")
	
endif()

if(NOT path)
	message(FATAL_ERROR "Could not find ${target} in ${type}")
endif()

get_filename_component(path "${path}" ABSOLUTE)

if(NOT IS_ABSOLUTE ${destination})
	set(destination "${CMAKE_INSTALL_PREFIX}/${destination}")
endif()
get_filename_component(destination "${destination}" ABSOLUTE)

get_filename_component(dir "${destination}/${target}" DIRECTORY)

file(COPY ${path} DESTINATION ${dir} USE_SOURCE_PERMISSIONS)

file(APPEND ${logfile} "${path}\n")
