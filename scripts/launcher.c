
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
	LPTSTR p = _tcsrchr(buffer, '\\') + 1;
	
	// Pass along the current executable directory
	#if LAUNCHER_USE_CMD_PATH
	*p = 0;
	SetEnvironmentVariable(STR(CAT(LAUNCHER_SCOMMAND, _PATH)), buffer);
	#endif
	
	// Determine the subdirectory for the appropriate variant
	LPCTSTR prefix;
	if(IsWow64()) {
		prefix = TEXT("bin\\x64\\");
	} else {
		prefix = TEXT("bin\\x86\\");
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
	if(!CreateProcess(buffer, GetCommandLine(), NULL, NULL, FALSE, flags, NULL, NULL, &si, &pi)) {
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
