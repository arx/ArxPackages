/*
 * Copyright (C) 2015 Daniel Scharrer
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the author(s) be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include <windows.h>

#ifndef LAUNCHER_USE_PATH
#define LAUNCHER_USE_PATH 0
#endif

#ifndef LAUNCHER_USE_CMD_PATH
#define LAUNCHER_USE_CMD_PATH 0
#endif

#define STR_HELPER(x) CAT(L, # x)
#define STR(x) STR_HELPER(x)
#define CAT_HELPER(x, y) x ## y
#define CAT(x, y) CAT_HELPER(x, y)
#define ARRAY_SIZE(a) (sizeof(a) / sizeof(*(a)))

static BOOL is_x64() {
	
	typedef BOOL (WINAPI * IsWow64Process_t)(HANDLE, PBOOL);
	typedef BOOL (WINAPI * IsWow64Process2_t)(HANDLE, USHORT *, USHORT *);
	
	// IsWow64Process is not available on all versions of Windows - load it dynamically.
	HMODULE handle = GetModuleHandleW(L"kernel32");
	HANDLE process = GetCurrentProcess();
	
	IsWow64Process2_t IsWow64Process2_p = (IsWow64Process2_t)GetProcAddress(handle, "IsWow64Process2");
	USHORT processArch;
	USHORT systemArch;
	if(IsWow64Process2_p && IsWow64Process2_p(process, &processArch, &systemArch)) {
		switch(systemArch) {
			case 0: break;
			case 0x8664: return TRUE;
			default:     return FALSE;
		}
	}
	
	IsWow64Process_t IsWow64Process_p = (IsWow64Process_t)GetProcAddress(handle, "IsWow64Process");
	BOOL result;
	if(IsWow64Process_p && IsWow64Process_p(process, &result)) {
		return result;
	}
	
	return FALSE;
}

typedef struct {
	WCHAR * p;
	unsigned slash_count;
} cmdline_state;

static cmdline_state append_cmdline(cmdline_state o, const WCHAR * str) {
	for(; *str; str++) {
		switch(*str) {
			case L'\\': o.slash_count++; break;
			case L'"': for(o.slash_count++; o.slash_count; o.slash_count--) { *o.p++ = L'\\'; } break;
			default: o.slash_count = 0;
		}
		*o.p++ = *str;
	}
	return o;
}

static WCHAR * path_end(WCHAR * path) {
	WCHAR * end = NULL;
	while(*path) {
		if(*path == L'\\' || *path == L'/') {
			end = path;
		}
		path++;
	}
	return end;
}

static WCHAR * copy(WCHAR * dest, const WCHAR * src) {
	while((*dest = *src)) {
		src++;
		dest++;
	}
	return dest;
}

__attribute__((visibility("default")))
__attribute__((noreturn))
__attribute__((nothrow))
extern void start() {
	
	DWORD buffer_size = sizeof(WCHAR) * MAX_PATH * 10;
	WCHAR * buffer = VirtualAlloc(0, buffer_size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
	
	// Get the path of this executable
	GetModuleFileNameW(NULL, buffer, buffer_size);
	WCHAR * p = path_end(buffer);
	
	// Fudge the commandline
	#ifdef LAUNCHER_ARGS
	WCHAR * cmdline = GetCommandLineW();
	int argc;
	WCHAR ** argv = CommandLineToArgvW(cmdline, &argc);
	*p = 0;
	cmdline = VirtualAlloc(0, 8191 * 2, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
	cmdline_state o = { cmdline, 0 };
	#define LAUNCHER_ARG_BEGIN()    *o.p++ = L' '; *o.p++ = L'"'
	#define LAUNCHER_ARG_TEXT(Text) o = append_cmdline(o, (Text));
	#define LAUNCHER_ARG_HERE()     LAUNCHER_ARG_TEXT(buffer)
	#define LAUNCHER_ARG_END()      for(; o.slash_count; o.slash_count--) { *o.p++ = L'\\'; }; *o.p++ = L'"'
	*o.p++ = L'"';
	LAUNCHER_ARG_TEXT(STR(LAUNCHER_COMMAND));
	LAUNCHER_ARG_END();
	LAUNCHER_ARGS;
	for(int i = 1; i < argc; i++) {
		LAUNCHER_ARG_BEGIN();
		LAUNCHER_ARG_TEXT(argv[i]);
		LAUNCHER_ARG_END();
	}
	*o.p = 0;
	#endif
	
	// Determine the subdirectory for the appropriate variant
	WCHAR * path;
	#if HAVE_X86 + HAVE_X64 > 1
	if(is_x64()) {
		path = L"\\bin\\x64\\" STR(LAUNCHER_COMMAND);
	} else {
		path = L"\\bin\\x86\\" STR(LAUNCHER_COMMAND);
	}
	#elif HAVE_X86
	path = L"\\bin\\x86\\" STR(LAUNCHER_COMMAND);
	#elif HAVE_X64
	path = L"\\bin\\x64\\" STR(LAUNCHER_COMMAND);
	#endif
	p = copy(p, path);
	
	#ifndef LAUNCHER_ARGS
	WCHAR * cmdline = GetCommandLineW();
	#endif
	
	// Start the selected variant
	DWORD exitcode = 42;
	STARTUPINFO si = { sizeof(si) };
	PROCESS_INFORMATION pi;
	DWORD flags = CREATE_UNICODE_ENVIRONMENT;
	if(CreateProcessW(buffer, cmdline, NULL, NULL, FALSE, flags, NULL, NULL, &si, &pi)) {
		WaitForSingleObject(pi.hProcess, INFINITE);
		GetExitCodeProcess(pi.hProcess, &exitcode);
	}
	
	ExitProcess(exitcode);
	
	__builtin_unreachable();
}
