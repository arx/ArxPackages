
!ifndef NEXT_INSTALL_BUTTON_INCLUDED
!define NEXT_INSTALL_BUTTON_INCLUDED

!include "LogicLib.nsh"
!include "WinMessages.nsh"

Function SetNextButtonToInstall
	
	Exch $0
	
	${If} $0 == 0
		GetDlgItem $0 $HWNDPARENT 1
		SendMessage $0 ${WM_SETTEXT} 0 "STR:$(^NextBtn)"
	${Else}
		GetDlgItem $0 $HWNDPARENT 1
		SendMessage $0 ${WM_SETTEXT} 0 "STR:$(^InstallBtn)"
	${EndIf}
	
	Pop $0
	
FunctionEnd

!macro SetNextButtonToInstall Install
	Push "${Install}"
	Call SetNextButtonToInstall
!macroend

!define SetNextButtonToInstall '!insertmacro SetNextButtonToInstall'

!endif ; NEXT_INSTALL_BUTTON_INCLUDED
