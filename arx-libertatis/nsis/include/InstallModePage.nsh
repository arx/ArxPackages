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

!include "ArxFatalisData.nsh"

!macro INSTALLMODE_PAGE
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageInstallModeOnPre
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!macroend

!macro INSTALLMODE_PAGE_FUNCTIONS

Function PageInstallModeOnPre
	
	${If} ${SectionIsSelected} ${PatchInstall}
		Push $0
		Push $1
		${GetArxFatalisLocationInfo} "$ArxFatalisLocation" $0 $1
		${If} $0 == ${MU_SYSTEM}
			Call MultiUser.InstallMode.AllUsers
			Abort
		${ElseIf} $0 == ${MU_USER}
			Call MultiUser.InstallMode.CurrentUser
			Abort
		${EndIf}
	${EndIf}
	
FunctionEnd

!macroend

