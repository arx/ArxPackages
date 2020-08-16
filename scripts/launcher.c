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

#include <tchar.h>

#ifndef LAUNCHER_USE_PATH
#define LAUNCHER_USE_PATH 0
#endif

#ifndef LAUNCHER_USE_CMD_PATH
#define LAUNCHER_USE_CMD_PATH 0
#endif

#ifndef LAUNCHER_WAIT
#define LAUNCHER_WAIT 0
#endif

#ifndef LAUNCHER_ATTACH_CONSOLE
#define LAUNCHER_ATTACH_CONSOLE 0
#endif

#define STR_HELPER(x) CAT(L, # x)
#define STR(x) STR_HELPER(x)
#define CAT_HELPER(x, y) x ## y
#define CAT(x, y) CAT_HELPER(x, y)
#define ARRAY_SIZE(a) (sizeof(a) / sizeof(*(a)))

#include <stdio.h>

static BOOL is_x64() {
	
	typedef BOOL (WINAPI * IsWow64Process_t)(HANDLE, PBOOL);
	typedef BOOL (WINAPI * IsWow64Process2_t)(HANDLE, USHORT *, USHORT *);
	
	// IsWow64Process is not available on all versions of Windows - load it dynamically.
	HMODULE handle = GetModuleHandle(TEXT("kernel32"));
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

static void flush_slashes(LPTSTR * opp, unsigned * slash_countp) {
	LPTSTR op = *opp;
	unsigned slash_count = *slash_countp;
	for(; slash_count; slash_count--) {
		*op++ = '\\';
		*op++ = '\\';
	}
	*opp = op;
	*slash_countp = 0;
}

static void append_cmdline(LPTSTR * opp, unsigned * slash_countp, LPCTSTR str) {
	LPTSTR op = *opp;
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

int CALLBACK WinMain(HINSTANCE a, HINSTANCE b, PSTR c, INT d) {
	
	// Save the console for our children
	#if LAUNCHER_ATTACH_CONSOLE
	if(AttachConsole(ATTACH_PARENT_PROCESS)) {
		freopen("CONOUT$", "wb", stdout);
		freopen("CONOUT$", "wb", stderr);
	}
	#endif
	
	// Get the path of this executable
	TCHAR buffer[MAX_PATH * 10];
	if(!GetModuleFileName(NULL, buffer, sizeof(buffer)) > 0) {
		return 1;
	}
	LPTSTR p = _tcsrchr(buffer, '\\');
	
	// Pass along the current executable directory
	#if LAUNCHER_USE_CMD_PATH
	*p = 0;
	SetEnvironmentVariable(STR(CAT(LAUNCHER_SCOMMAND, _PATH)), buffer);
	#endif
	
	// Fudge the commandline
	LPTSTR cmdline = GetCommandLine();
	#ifdef LAUNCHER_ARGS
	*p = 0;
	TCHAR newcmdline[8191 * 2];
	LPTSTR op = newcmdline;
	unsigned slash_count = 0;
	int n;
	LPTSTR * args = CommandLineToArgvW(cmdline, &n);
	TCHAR invocation[MAX_PATH];
	_tcscpy(invocation, args[0]);
	LPTSTR ip = _tcsrchr(invocation, '\\');
	if(ip) {
		ip++;
	} else {
		ip = invocation;
	}
	_tcscpy(invocation, STR(LAUNCHER_COMMAND));
	#define LAUNCHER_ARG_BEGIN()    *op++ = ' '; *op++ = '"'
	#define LAUNCHER_ARG_TEXT(Text) append_cmdline(&op, &slash_count, (Text));
	#define LAUNCHER_ARG_HERE()     LAUNCHER_ARG_TEXT(buffer)
	#define LAUNCHER_ARG_END()      flush_slashes(&op, &slash_count); *op++ = '"'
	*op++ = '"';
	LAUNCHER_ARG_TEXT(invocation);
	LAUNCHER_ARG_END();
	LAUNCHER_ARGS;
	int i = 1;
	for(; i < n; i++) {
		LAUNCHER_ARG_BEGIN();
		LAUNCHER_ARG_TEXT(args[i]);
		LAUNCHER_ARG_END();
	}
	*op = 0;
	cmdline = newcmdline;
	#endif
	
	// Determine the subdirectory for the appropriate variant
	LPCTSTR prefix;
	if(is_x64()) {
		prefix = TEXT("\\bin\\x64");
	} else {
		prefix = TEXT("\\bin\\x86");
	}
	DWORD plen = _tcslen(prefix);
	memcpy(p, prefix, plen * sizeof(TCHAR));
	p += plen;
	
	// Adjust %PATH%
	#if LAUNCHER_USE_PATH
	LPTSTR pp = p;
	*pp++ = ';';
	DWORD ppsize = ARRAY_SIZE(buffer) - (pp - buffer);
	DWORD pathlen = GetEnvironmentVariable(L"PATH", pp, ppsize);
	if(pathlen && pathlen < ppsize) {
		SetEnvironmentVariable(L"PATH", buffer);
	}
	#endif
	
	// Append the target command name
	const TCHAR * const command = STR(LAUNCHER_COMMAND);
	DWORD clen = _tcslen(command);
	*p++ = '\\';
	memcpy(p, command, clen * sizeof(TCHAR));
	p += clen;
	
	*p = 0;
	
	// Start the selected variant
	STARTUPINFO si;
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	PROCESS_INFORMATION pi;
	ZeroMemory(&pi, sizeof(pi));
	DWORD flags = CREATE_UNICODE_ENVIRONMENT;
	if(!CreateProcess(buffer, cmdline, NULL, NULL, FALSE, flags, NULL, NULL, &si, &pi)) {
		return 1;
	}
	
	#if LAUNCHER_WAIT
	DWORD exitcode;
	WaitForSingleObject(pi.hProcess, INFINITE);
	if(!GetExitCodeProcess(pi.hProcess, &exitcode)) {
		return 1;
	}
	return exitcode;
	#else
	return 0;
	#endif
}
