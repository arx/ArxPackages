
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

BOOL IsWow64() {
	
	typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);
	BOOL bIsWow64;
	HMODULE handle;
	LPFN_ISWOW64PROCESS fnIsWow64Process;
	
	//IsWow64Process is not available on all supported versions of Windows.
	//Use GetModuleHandle to get a handle to the DLL that contains the function
	//and GetProcAddress to get a pointer to the function if available.
	handle = GetModuleHandle(TEXT("kernel32"));
	fnIsWow64Process = (LPFN_ISWOW64PROCESS)GetProcAddress(handle,"IsWow64Process");
	if(!fnIsWow64Process) {
		return FALSE;
	}
	
	if(!fnIsWow64Process(GetCurrentProcess(), &bIsWow64)) {
		return FALSE; // WTF
	}
	
	return bIsWow64;
}

void flush_slashes(LPTSTR * opp, unsigned * slash_countp) {
	LPTSTR op = *opp;
	unsigned slash_count = *slash_countp;
	for(; slash_count; slash_count--) {
		*op++ = '\\';
		*op++ = '\\';
	}
	*opp = op;
	*slash_countp = 0;
}

void append_cmdline(LPTSTR * opp, unsigned * slash_countp, LPCTSTR str) {
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
	if(IsWow64()) {
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
	#endif
	
	// Close process and thread handles. 
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
	
	#if LAUNCHER_WAIT
	return exitcode;
	#else
	return 0;
	#endif
}
