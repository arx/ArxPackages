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

!include "ProgressBar.nsh"

!macro INSTFILES_PAGE
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageInstFilesOnShow
!insertmacro MUI_PAGE_INSTFILES
!macroend

!macro INSTFILES_PAGE_FUNCTIONS

Function PageInstFilesOnShow
	
	Push $0
	
	${ProgressBarReplace} $mui.InstFilesPage.ProgressBar
	
	; Main
	${ProgressBarAddToTotal} ${MAIN_SECTION_SIZE} ${MAIN_SECTION_COUNT}
	
	; CopyData
	SectionGetSize ${CopyData} $0
	${If} ${SectionIsSelected} ${CopyData}
		${If} $ArxFatalisLocation == $INSTDIR
			${ProgressBarAddToTotal} 0 0
		${Else}
			${ProgressBarAddToTotal} "$0" $ArxFatalisFileCount
		${EndIf}
	${EndIf}
	
	; Cleanup
	${ProgressBarAddToTotal} 0 0
	
	; VerifyData - checks as much bytes as CopyData copies
	${If} $ArxFatalisLocation != ""
		${ProgressBarAddToTotal} "$0" $ArxFatalisFileCount
	${EndIf}
	
	Pop $0
	
FunctionEnd

!macroend
