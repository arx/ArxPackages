
!ifndef NEXT_INSTALL_BUTTON_INCLUDED
!define NEXT_INSTALL_BUTTON_INCLUDED

!include "LogicLib.nsh"
!include "WinMessages.nsh"

Function SetNextButtonText
	
	Exch $0 ; Text
	Push $1
	
	GetDlgItem $1 $HWNDPARENT 1
	SendMessage $1 ${WM_SETTEXT} 0 "STR:$0"
	
	Pop $1
	Pop $0
	
FunctionEnd

!macro SetNextButtonText Text
	Push "${Text}"
	Call SetNextButtonText
!macroend

!define SetNextButtonText '!insertmacro SetNextButtonText'

Function SetNextButtonToInstall
	
	Exch $0
	
	${If} $0 == 0
		${SetNextButtonText} "$(^NextBtn)"
	${Else}
		${SetNextButtonText} "$(^InstallBtn)"
	${EndIf}
	
	Pop $0
	
FunctionEnd

!macro SetNextButtonToInstall Install
	Push "${Install}"
	Call SetNextButtonToInstall
!macroend

!define SetNextButtonToInstall '!insertmacro SetNextButtonToInstall'

!endif ; NEXT_INSTALL_BUTTON_INCLUDED
