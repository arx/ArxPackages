
; From https://nsis.sourceforge.io/Allow_only_one_installer_instance

!ifndef NSIS_PTR_SIZE & SYSTYPE_PTR
!define SYSTYPE_PTR i ; NSIS v2.x
!else
!define /ifndef SYSTYPE_PTR p ; NSIS v3.0+
!endif

!macro ActivateOtherInstance
StrCpy $3 "" ; Start FindWindow with NULL
loop:
	FindWindow $3 "#32770" "" "" $3
	StrCmp 0 $3 windownotfound
	StrLen $0 "$(^UninstallCaption)"
	IntOp $0 $0 + 1 ; GetWindowText count includes \0
	System::Call 'USER32::GetWindowText(${SYSTYPE_PTR}r3, t.r0, ir0)'
	StrCmp $0 "$(^UninstallCaption)" windowfound ""
	StrLen $0 "$(^SetupCaption)"
	IntOp $0 $0 + 1 ; GetWindowText count includes \0
	System::Call 'USER32::GetWindowText(${SYSTYPE_PTR}r3, t.r0, ir0)'
	StrCmp $0 "$(^SetupCaption)" windowfound loop
windowfound:
	SendMessage $3 0x112 0xF120 0 /TIMEOUT=2000 ; WM_SYSCOMMAND:SC_RESTORE to restore the window if it is minimized
	System::Call "USER32::SetForegroundWindow(${SYSTYPE_PTR}r3)"
	Goto +2
windownotfound:
	MessageBox MB_OK|MB_ICONSTOP "$(SINGLE_INSTANCE)"
!macroend

!macro SingleInstanceMutex
!ifndef INSTALLERMUTEXNAME
!error "Must define INSTALLERMUTEXNAME"
!endif
System::Call 'KERNEL32::CreateMutex(${SYSTYPE_PTR}0, i1, t"${INSTALLERMUTEXNAME}")?e'
Pop $0
IntCmpU $0 183 "" launch launch ; ERROR_ALREADY_EXISTS?
	!insertmacro ActivateOtherInstance
	Abort
launch:
!macroend
