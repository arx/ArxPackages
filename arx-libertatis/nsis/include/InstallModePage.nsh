;------------------------------------------------------------------------------
; Copyright 2021 Arx Libertatis Team (see the AUTHORS file)
;
; This file is part of Arx Libertatis.
;
; Arx Libertatis is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; Arx Libertatis is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Arx Libertatis.  If not, see <http://www.gnu.org/licenses/>.
;------------------------------------------------------------------------------

!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "MultiUser.nsh"

!include "NextInstallButton.nsh"

!include "ArxFatalisData.nsh"

!macro INSTALLMODE_PAGE
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageInstallModeOnPre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageInstallModeOnShow
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!macroend

!macro INSTALLMODE_PAGE_FUNCTIONS

Function PageInstallModeIsInstall
	
	Push $0
	
	${If} $SelectedInstType == ${INSTTYPE_UPDATE_REPAIR}
	${OrIf} ${SectionIsSelected} ${PatchInstall}
		${If} $SelectedInstType == ${INSTTYPE_UPDATE_REPAIR}
			StrCpy $0 $ExistingInstallMode
		${Else}
			${GetArxFatalisInstallMode} "$ArxFatalisLocation" $0
		${EndIf}
		${If} $0 == "AllUsers"
		${OrIf} $0 == "CurrentUser"
			Call PageDirectoryIsInstall
			Pop $0
		${Else}
			StrCpy $0 0
		${EndIf}
	${Else}
		StrCpy $0 0
	${EndIf}
	
	Exch $0
	
FunctionEnd

Function PageInstallModeOnPre
	
	${If} $SelectedInstType == ${INSTTYPE_UPDATE_REPAIR}
	${OrIf} ${SectionIsSelected} ${PatchInstall}
		Push $0
		${If} $SelectedInstType == ${INSTTYPE_UPDATE_REPAIR}
			StrCpy $0 $ExistingInstallMode
		${Else}
			${GetArxFatalisInstallMode} "$ArxFatalisLocation" $0
		${EndIf}
		${If} $0 == "AllUsers"
			Call MultiUser.InstallMode.AllUsers
			Pop $0
			Abort
		${ElseIf} $0 == "CurrentUser"
			Call MultiUser.InstallMode.CurrentUser
			Pop $0
			Abort
		${EndIf}
		Pop $0
	${EndIf}
	
FunctionEnd

Function PageInstallModeOnShow
	
	Call PageDirectoryIsInstall
	Call SetNextButtonToInstall
	
FunctionEnd

!macroend

