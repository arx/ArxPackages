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

!include "NextInstallButton.nsh"
!include "PathUtil.nsh"

!macro DIRECTORY_PAGE
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageDirectoryOnPre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageDirectoryOnShow
!insertmacro MUI_PAGE_DIRECTORY
!macroend

!macro DIRECTORY_PAGE_FUNCTIONS

Function PageDirectoryIsInstall
	
	${If} $SelectedInstType == ${INSTTYPE_UPDATE_REPAIR}
	${OrIf} $SelectedInstType == ${INSTTYPE_UNINSTALL}
	${OrIf} ${SectionIsSelected} ${PatchInstall}
		Call PageStartMenuIsInstall
	${Else}
		Push 0
	${EndIf}
	
FunctionEnd

Function PageDirectoryOnPre
	
	${If} $SelectedInstType == ${INSTTYPE_UPDATE_REPAIR}
	${OrIf} $SelectedInstType == ${INSTTYPE_UNINSTALL}
		StrCpy $INSTDIR "$ExistingInstallLocation"
		Abort
	${ElseIf} ${SectionIsSelected} ${PatchInstall}
		StrCpy $INSTDIR "$ArxFatalisLocation"
		Abort
	${EndIf}
	
	; Use existing install location if available
	${If} $MultiUser.InstallMode == $ExistingInstallMode
		${If} $ExistingInstallType == "separate"
			StrCpy $INSTDIR "$ExistingInstallLocation"
		${EndIf}
	${Else}
		Push $0
		Push $1
		ReadRegStr $0 SHCTX "Software\ArxLibertatis" "InstallType"
		ReadRegStr $1 SHCTX "Software\ArxLibertatis" "InstallLocation"
		${If} $1 == ""
			ReadRegStr $0 SHCTX "Software\Wow6432Node\ArxLibertatis" "InstallType"
			ReadRegStr $1 SHCTX "Software\Wow6432Node\ArxLibertatis" "InstallLocation"
		${EndIf}
		${If} $0 == ""
			${Map.Get} $0 ArxFatalisLocationInfo "$1"
			${If} $0 == __NULL
				StrCpy $0 "separate"
			${EndIf}
		${EndIf}
		${If} $0 == "separate"
		${AndIf} $1 != ""
		${AndIf} ${FileExists} "$1\*.*"
			${NormalizePath} "$1" $INSTDIR
		${EndIf}
	${EndIf}
	
FunctionEnd

Function PageDirectoryOnShow
	
	Call PageStartMenuIsInstall
	Call SetNextButtonToInstall
	
FunctionEnd

Function .onVerifyInstDir
	
	Push $0
	
	${NormalizePath} "$INSTDIR" $0
	${If} $0 == $ArxFatalisLocation
		Pop $0
		Abort
	${EndIf}
	
	Pop $0
	
FunctionEnd

!macroend
