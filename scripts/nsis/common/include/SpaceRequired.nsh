
!ifndef SPACE_REQUIRED
!define SPACE_REQUIRED

!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "NSISList.nsh"
!include "WinMessages.nsh"

!include "PathUtil.nsh"

; ${SpaceRequiredReplace} WidgetVar
!define SpaceRequiredReplace '!insertmacro SpaceRequiredReplace'

!macro SpaceRequiredReplace WidgetVar
	Push "${WidgetVar}"
	Call SpaceRequiredReplace
	Pop ${WidgetVar}
!macroend

Function SpaceRequiredReplace
	
	Exch $0 ; Old widget
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
	
	; Hide the old label
	ShowWindow $0 ${SW_HIDE}
	
	; Create a new label in place of the old one
	System::Call 'USER32::CreateWindowEx(i0, t"static", t"", i${DEFAULT_STYLES}, ir2, ir3, ir4, ir5, pr1, p0, p0, p0)p.s'
	Pop $0
	
	CreateFont $1 "$(^Font)" "$(^FontSize)"
	SendMessage $0 ${WM_SETFONT} $1 1
	
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0 ; New widget
	
FunctionEnd

; ${SpaceRequiredFormat} Kilobytes Result
!define SpaceRequiredFormat '!insertmacro SpaceRequiredFormat'

!macro SpaceRequiredFormat Kilobytes Result
	Push "${Kilobytes}"
	Call SpaceRequiredFormat
	Pop ${Result}
!macroend

Function SpaceRequiredFormat
	
	Exch $0 ; Kilobytes
	Push $1
	
	System::Int64Op $0 / 1073741824
	Pop $1
	${If} $1 != 0
		System::Int64Op $0 * 10
		Pop $0
		System::Int64Op $0 / 1073741824
		Pop $0
		System::Int64Op $0 % 10
		Pop $0
		StrCpy $0 "$1.$0 $(^tera)$(^byte)"
	${Else}
		System::Int64Op $0 / 1048576
		Pop $1
		${If} $1 != 0
			System::Int64Op $0 * 10
			Pop $0
			System::Int64Op $0 / 1048576
			Pop $0
			IntOp $0 $0 % 10
			StrCpy $0 "$1.$0 $(^giga)$(^byte)"
		${Else}
			IntOp $1 $0 / 1024
			${If} $1 != 0
				IntOp $0 $0 * 10
				IntOp $0 $0 / 1024
				IntOp $0 $0 % 10
				StrCpy $0 "$1.$0 $(^mega)$(^byte)"
			${Else}
				StrCpy $0 "$0 $(^kilo)$(^byte)"
			${EndIf}
		${EndIf}
	${EndIf}
	
	Pop $1
	Exch $0
	
FunctionEnd

; ${SpaceRequired} Widget Kilobytes
!define SpaceRequired '!insertmacro SpaceRequired'

!macro SpaceRequired Widget Kilobytes
	Push "${Kilobytes}"
	Push "${Widget}"
	Call SpaceRequired
!macroend

Function SpaceRequired
	
	Exch $0 ; Widget
	Exch
	Exch $1 ; Kilobytes
	Push $2
	Push $3
	Push $4
	
	${If} $1 < 0
		StrCpy $2 "$(SPACE_FREED)"
		IntOp $1 0 - $1
	${Else}
		StrCpy $2 "$(^SpaceRequired)"
	${EndIf}
	
	${SpaceRequiredFormat} "$1" $3
	SendMessage $0 ${WM_SETTEXT} 0 "STR:$2$3"
	
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

; ${SpaceRequiredGet} Overrides Result
!define SpaceRequiredGet '!insertmacro SpaceRequiredGet'

!macro SpaceRequiredGet Overrides Result
	Push ${SECTION_MAX}
	Push "${Overrides}"
	Call SpaceRequiredGet
	Pop ${Result}
!macroend

Function SpaceRequiredGet
	
	Exch $0
	Exch
	Exch $1
	Push $2
	Push $3
	
	StrCpy $3 0
	
	${DoWhile} $1 >= 0
		${If} ${SectionIsSelected} $1
			${Map.Get} $2 $0 $1
			${If} $2 == __NULL
				SectionGetSize $1 $2
			${EndIf}
			IntOp $3 $3 + $2
		${EndIf}
		IntOp $1 $1 - 1
	${Loop}
	
	StrCpy $0 $3
	
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

; ${SpaceRequiredUpdate} Widget Overrides
!define SpaceRequiredUpdate '!insertmacro SpaceRequiredUpdate'

!macro SpaceRequiredUpdate Widget Overrides
	Push ${SECTION_MAX}
	Push "${Overrides}"
	Call SpaceRequiredGet
	Push "${Widget}"
	Call SpaceRequired
!macroend

; ${SpaceFreeGet} Path RequiredKilobytes Result
!define SpaceRequiredCheck '!insertmacro SpaceRequiredCheck'

!macro SpaceRequiredCheck Path RequiredKilobytes Result
	Push "${RequiredKilobytes}"
	Push "${Path}"
	Call SpaceRequiredCheck
	Pop ${Result}
!macroend

Function SpaceRequiredCheck
	
	Exch $0 ; Path
	Exch
	Exch $1 ; RequiredKilobytes
	
	${DoUntil} ${FileExists} "$0"
		${GetDirectory} "$0" $0
		${If} $0 == ""
			Pop $1
			Exch $0
			Return
		${EndIf}
	${Loop}
	
	System::Call 'kernel32::GetDiskFreeSpaceExW(tr0, *l.r0, *l, *l)i.n'
	
	; Bytes → KB
	System::Int64Op $0 / 1024
	Pop $0
	
	System::Int64Op $0 >= $1
	Pop $1
	${If} $1 == 1
		StrCpy $0 ""
	${EndIf}
	
	Pop $1
	Exch $0
	
FunctionEnd

!endif ; SPACE_REQUIRED
