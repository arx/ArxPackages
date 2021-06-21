
!ifndef PROGRESS_BAR
!define PROGRESS_BAR

!include "LogicLib.nsh"
!include "WinMessages.nsh"

!include "PathUtil.nsh"

Var ProgressBar
Var ProgressBarTotal
Var ProgressBarLimit
Var ProgressBarValue

!ifndef PROGRESS_BAR_ITEM_OVERHEAD
!define PROGRESS_BAR_ITEM_OVERHEAD 1024
!endif

!ifndef PROGRESS_BAR_SECTION_OVERHEAD
!define PROGRESS_BAR_SECTION_OVERHEAD 10240
!endif

!define PROGRESS_BAR_MAX 512
!define /math PROGRESS_BAR_RANGE ${PROGRESS_BAR_MAX} << 16

Function ProgressBarReplace
	
	Exch $0 ; Old progress bar
	Push $1
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6
	
	; Get the parent window
	System::Call 'USER32::GetParent(pr0)p.r1'
	
	; Get the size and position of the old progress bar relative to the parent window
	System::Alloc 16
	Pop $6
	System::Call 'USER32::GetWindowRect(pr0, pr6)i.n'
	System::Call 'USER32::MapWindowPoints(p0, pr1, pr6, i2)i.n'
	System::Call '*$6(i.r2, i.r3, i.r4, i.r5)'
	System::Free $6
	IntOp $4 $4 - $2
	IntOp $5 $5 - $3
	
	; Create a new progress bar in place of the old one
	System::Call 'USER32::CreateWindowEx(i0, t"msctls_progress32", t"", i1342177281, ir2, ir3, ir4, ir5, pr1, p0, p0, p0)p.s'
	Pop $ProgressBar
	StrCpy $ProgressBarTotal 0
	StrCpy $ProgressBarValue 0
	StrCpy $ProgressBarLimit 0
	SendMessage $ProgressBar ${PBM_SETRANGE} 0 ${PROGRESS_BAR_RANGE}
	
	; Hide the old progress bar
	ShowWindow $0 ${SW_HIDE}
	
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro ProgressBarReplace OldWidget
	Push "${OldWidget}"
	Call ProgressBarReplace
!macroend

; ${ProgressBarReplace} OldWidget
!define ProgressBarReplace '!insertmacro ProgressBarReplace'

Function ProgressBarAddToTotal
	
	Exch $0 ; Size
	Exch
	Exch $1 ; Items
	
	IntOp $ProgressBarTotal $ProgressBarTotal + $0
	IntOp $1 $1 * ${PROGRESS_BAR_ITEM_OVERHEAD}
	IntOp $ProgressBarTotal $ProgressBarTotal + $1
	
	Pop $1
	Pop $0
	
FunctionEnd

!macro ProgressBarAddToTotal Size Items
	Push "${Items}"
	Push "${Size}"
	Call ProgressBarAddToTotal
!macroend

; ${ProgressBarAddToTotal} Size Items
!define ProgressBarAddToTotal '!insertmacro ProgressBarAddToTotal'

Function ProgressBarSetPos
	
	Exch $0 ; New value
	Push $1
	Push $2
	
	${If} $0 > $ProgressBarTotal
		StrCpy $0 $ProgressBarTotal
	${EndIf}
	
	IntOp $1 $ProgressBarTotal / ${PROGRESS_BAR_MAX}
	IntOp $1 $ProgressBarValue / $1
	
	StrCpy $ProgressBarValue $0
	
	IntOp $0 $ProgressBarTotal / ${PROGRESS_BAR_MAX}
	IntOp $0 $ProgressBarValue / $0
	
	${If} $0 != $1
		SendMessage $ProgressBar ${PBM_SETPOS} $0 0
	${EndIf}
	
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro ProgressBarSetPos Pos
	Push "${Pos}"
	Call ProgressBarSetPos
!macroend

; ${ProgressBarSetPos} Pos
!define ProgressBarSetPos '!insertmacro ProgressBarSetPos'

Function ProgressBarBeginSection
	
	Exch $0 ; Size
	Exch
	Exch $1 ; Items
	
	IntOp $ProgressBarLimit $ProgressBarLimit + $0
	IntOp $1 $1 * ${PROGRESS_BAR_ITEM_OVERHEAD}
	IntOp $ProgressBarLimit $ProgressBarLimit + $1
	IntOp $ProgressBarLimit $ProgressBarLimit + ${PROGRESS_BAR_SECTION_OVERHEAD}
	${If} $ProgressBarLimit > $ProgressBarTotal
		StrCpy $ProgressBarLimit $ProgressBarTotal
	${EndIf}
	
	Pop $1
	Pop $0
	
FunctionEnd

!macro ProgressBarBeginSection Size Items
	Push "${Items}"
	Push "${Size}"
	Call ProgressBarBeginSection
!macroend

; ${ProgressBarBeginSection} Size Items
!define ProgressBarBeginSection '!insertmacro ProgressBarBeginSection'

Function ProgressBarUpdate
	
	Exch $0 ; Size
	
	IntOp $0 $0 + $ProgressBarValue
	IntOp $0 $0 + ${PROGRESS_BAR_ITEM_OVERHEAD}
	${If} $0 > $ProgressBarLimit
		StrCpy $0 $ProgressBarLimit
	${EndIf}
	${ProgressBarSetPos} $0
	
	Pop $0
	
FunctionEnd

!macro ProgressBarUpdate Size
	Push "${Size}"
	Call ProgressBarUpdate
!macroend

; ${ProgressBarUpdate} Size
!define ProgressBarUpdate '!insertmacro ProgressBarUpdate'

Function ProgressBarFile
	
	Exch $0
	
	${GetFileSize} "$0" $0
	${ProgressBarUpdate} "$0"
	
	Pop $0
	
FunctionEnd

!macro ProgressBarFile Path
	Push "${Path}"
	Call ProgressBarFile
!macroend

; ${ProgressBarFile} Path
!define ProgressBarFile '!insertmacro ProgressBarFile'

; ${ProgressBarEndSection}
!define ProgressBarEndSection '${ProgressBarSetPos} $ProgressBarLimit'

!endif ; PROGRESS_BAR
