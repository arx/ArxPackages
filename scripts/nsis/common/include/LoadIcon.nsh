
!include "LogicLib.nsh"
!include "nsDialogs.nsh"

!ifndef LoadSmallIcon

!define IDI_APPLICATION 32512
!define IDI_ERROR 32513
!define IDI_QUESTION 32514
!define IDI_WARNING 32515
!define IDI_INFORMATION 32516
!define IDI_WINLOGO 32517
!define IDI_SHIELD 32518

!define LIM_SMALL 0
!define SM_CXSMICON 49
!define SM_CYSMICON 50

!define LIM_LARGE 1
!define SM_CXICON 11
!define SM_CYICON 12

Function LoadSmallIcon
	
	Exch $0
	Push $1
	
	StrCpy $1 0
	
	; Try to get a HiDPI-compatible icon handle on Vista or newer
	System::Call 'COMCTL32::LoadIconMetric(p0, pr0, i${LIM_SMALL}, *p0r1)i.n'
	
	${If} $1 == 0
		; Fallback for Windows XP
		; LoadIcon* has fake resource IDs for standard icons, translate them to real ones in user32.dll
		; This mapping is not stable, but we only need it to work on XP where we have not other way to do it.
		${If} $0 == 32512
			StrCpy $0 100
		${ElseIf} $0 == 32513
			StrCpy $0 103
		${ElseIf} $0 == 32514
			StrCpy $0 102
		${ElseIf} $0 == 32515
			StrCpy $0 101
		${ElseIf} $0 == 32516
			StrCpy $0 104
		${ElseIf} $0 == 32517
			StrCpy $0 105
		${ElseIf} $0 == 32518
			StrCpy $0 106
		${EndIf}
		System::Call 'USER32::GetSystemMetrics(i${SM_CYSMICON})i.s'
		System::Call 'USER32::GetSystemMetrics(i${SM_CXSMICON})i.s'
		System::Call 'KERNEL32::GetModuleHandle(t"user32.dll")p.s'
		System::Call 'USER32::LoadImage(ps, pr0, i${IMAGE_ICON}, is, is, i0)p.r1'
	${EndIf}
	
	Exch
	Pop $0
	Exch $1
	
FunctionEnd

!macro LoadSmallIcon Resource Result
	Push ${Resource}
	Call LoadSmallIcon
	Pop ${Result}
!macroend

!define LoadSmallIcon "!insertmacro LoadSmallIcon"

!endif
