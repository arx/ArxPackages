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

Var StartMenuFolder

!macro STARTMENU_PAGE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "SHCTX"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ArxLibertatis"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Arx Libertatis"
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageStartMenuOnPre
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!macroend

!macro STARTMENU_PAGE_FUNCTIONS

Function PageStartMenuIsInstall
	
	${If} ${SectionIsSelected} ${PatchInstall}
		Push 1
	${Else}
		Push 0
	${EndIf}
	
FunctionEnd

Function PageStartMenuOnPre
	
	${If} ${SectionIsSelected} ${PatchInstall}
		Abort
	${EndIf}
	
FunctionEnd

!macroend

