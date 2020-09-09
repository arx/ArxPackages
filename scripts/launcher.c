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

#ifndef LAUNCHER_ATTACH_CONSOLE
#define LAUNCHER_ATTACH_CONSOLE 0
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

static void flush_slashes(WCHAR ** opp, unsigned * slash_countp) {
	WCHAR * op = *opp;
	unsigned slash_count = *slash_countp;
	for(; slash_count; slash_count--) {
		*op++ = '\\';
		*op++ = '\\';
	}
	*opp = op;
	*slash_countp = 0;
}

static void append_cmdline(WCHAR ** opp, unsigned * slash_countp, const WCHAR * str) {
	WCHAR * op = *opp;
	unsigned slash_count = *slash_countp;
	for(; *str; str++) {
		switch(*str) {
			case '\\': slash_count++; continue;
			case '"': flush_slashes(&op, &slash_count);
		}
		for(; slash_count; slash_count--) {
			*op++ = '\\';
		}
		*op++ = *str;
	}
	*opp = op;
	*slash_countp = slash_count;
}

static WCHAR * path_end(WCHAR * path) {
	WCHAR * end = NULL;
	while(*path) {
		if(*path == L'\\') {
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

__attribute__((__visibility__("default")))
extern void start() {
	
	// Save the console for our children
	#if LAUNCHER_ATTACH_CONSOLE
	AttachConsole(ATTACH_PARENT_PROCESS);
	#endif
	
	DWORD buffer_size = sizeof(WCHAR) * MAX_PATH * 10;
	WCHAR * buffer = VirtualAlloc(0, buffer_size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
	
	// Get the path of this executable
	GetModuleFileNameW(NULL, buffer, buffer_size);
	WCHAR * p = path_end(buffer);
	
	// Pass along the current executable directory
	#if LAUNCHER_USE_CMD_PATH
	*p = 0;
	SetEnvironmentVariableW(STR(CAT(LAUNCHER_SCOMMAND, _PATH)), buffer);
	#endif
	
	// Fudge the commandline
	WCHAR * cmdline = GetCommandLineW();
	#ifdef LAUNCHER_ARGS
	int n;
	WCHAR ** args = CommandLineToArgvW(cmdline, &n);
	#if !LAUNCHER_USE_CMD_PATH
	*p = 0;
	#endif
	WCHAR * op = cmdline = VirtualAlloc(0, 8191 * 2, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
	unsigned slash_count = 0;
	#define LAUNCHER_ARG_BEGIN()    *op++ = ' '; *op++ = '"'
	#define LAUNCHER_ARG_TEXT(Text) append_cmdline(&op, &slash_count, (Text));
	#define LAUNCHER_ARG_HERE()     LAUNCHER_ARG_TEXT(buffer)
	#define LAUNCHER_ARG_END()      flush_slashes(&op, &slash_count); *op++ = '"'
	*op++ = '"';
	LAUNCHER_ARG_TEXT(STR(LAUNCHER_COMMAND));
	LAUNCHER_ARG_END();
	LAUNCHER_ARGS;
	int i = 1;
	for(; i < n; i++) {
		LAUNCHER_ARG_BEGIN();
		LAUNCHER_ARG_TEXT(args[i]);
		LAUNCHER_ARG_END();
	}
	*op = 0;
	#endif
	
	// Determine the subdirectory for the appropriate variant
	WCHAR * prefix;
	#if HAVE_X86 + HAVE_X64 > 1
	if(is_x64()) {
		prefix = L"\\bin\\x64\\";
	} else {
		prefix = L"\\bin\\x86\\";
	}
	#elif HAVE_X86
	prefix = L"\\bin\\x86\\";
	#elif HAVE_X64
	prefix = L"\\bin\\x64\\";
	#endif
	p = copy(p, prefix);
	
	// Adjust %PATH%
	#if LAUNCHER_USE_PATH
	WCHAR * pp = p;
	*pp++ = ';';
	DWORD ppsize = buffer_size - (pp - buffer);
	DWORD pathlen = GetEnvironmentVariableW(L"PATH", pp, ppsize);
	if(pathlen && pathlen < ppsize) {
		SetEnvironmentVariableW(L"PATH", buffer);
	}
	#endif
	
	// Append the target command name
	p = copy(p, STR(LAUNCHER_COMMAND));
	
	// Start the selected variant
	STARTUPINFO si = { sizeof(si) };
	PROCESS_INFORMATION pi;
	DWORD flags = CREATE_UNICODE_ENVIRONMENT;
	if(!CreateProcessW(buffer, cmdline, NULL, NULL, FALSE, flags, NULL, NULL, &si, &pi)) {
		ExitProcess(42);
	}
	
	WaitForSingleObject(pi.hProcess, INFINITE);
	DWORD exitcode = 1;
	GetExitCodeProcess(pi.hProcess, &exitcode);
	ExitProcess(exitcode);
	
}
