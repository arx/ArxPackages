#define UNICODE
#define _UNICODE
#define LOADER_WAIT

#include <windows.h>

#include <tchar.h>

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
	AttachConsole(ATTACH_PARENT_PROCESS);
	
	TCHAR buffer[MAX_PATH];
	LPTSTR p;
	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	LPCTSTR prefix;
	int plen;
	#ifdef LOADER_WAIT
	DWORD exitcode;
	#endif
	
	// Get the path of this executable
	if(!GetModuleFileName(NULL, buffer, sizeof(buffer)) > 0) {
		return 1337;
	}
	
	// Determine the subdirectory for the appropriate variant
	if(IsWow64()) {
		prefix = TEXT("bin\\x64\\");
	} else {
		prefix = TEXT("bin\\x86\\");
	}
	plen = _tcslen(prefix);
	
	// Inject the subdirectory into the path
	p = _tcsrchr(buffer, '\\') + 1;
	memmove(p + plen, p, (_tcslen(buffer) - (p - buffer) + 1) * sizeof(TCHAR));
	memcpy(p, prefix, plen * sizeof(TCHAR));
	
	// Start the selected variant
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));
	if(!CreateProcess(buffer, GetCommandLine(), NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
		return 1337;
	}
	
	#ifdef LOADER_WAIT
	WaitForSingleObject(pi.hProcess, INFINITE);
	if(!GetExitCodeProcess(pi.hProcess, &exitcode)) {
		return 1337;
	}
	#endif
	
	// Close process and thread handles. 
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
	
	#ifdef LOADER_WAIT
	return exitcode;
	#else
	return 0;
	#endif
}
