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
!include "Sections.nsh"

!include "NextInstallButton.nsh"

Var SecPatchInstall
Var SecSeparateInstall
Var SecCopyData
Var SecStartMenu
Var SecDesktop
Var SecQuickLaunch

!macro COMPONENTS_PAGE
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageComponentsOnPre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageComponentsOnShow
!insertmacro MUI_PAGE_COMPONENTS
!macroend

!macro COMPONENTS_PAGE_INIT
	StrCpy $SecPatchInstall ${SF_SELECTED}
	StrCpy $SecSeparateInstall 0
	StrCpy $SecCopyData 0
	StrCpy $SecDesktop ${SF_SELECTED}
	StrCpy $SecQuickLaunch 0
	${If} ${AtLeastWin7}
		; Quick Launch toolbar was removed in Windows 7 so don't bother asking users for it
		SectionSetText ${QuickLaunch} "" ; Remove text to hide the section
	${EndIf}
	!insertmacro SectionUngroup ${PatchInstall}
	!insertmacro SectionUngroup ${SeparateInstall}
!macroend

!macro SaveSectionState SectionIndex Variable
	SectionGetFlags ${SectionIndex} ${Variable}
	IntOp ${Variable} ${Variable} & ${SF_SELECTED}
!macroend

!define /math SF_SELECTED_AND_RO ${SF_SELECTED} | ${SF_RO}
!define /math NOT_SF_SELECTED ${SF_SELECTED} ~
!define /math NOT_SF_RO ${SF_RO} ~
!define /math NOT_SF_SECGRP ${SF_SECGRP} ~
!define /math NOT_SF_PSELECTED ${SF_PSELECTED} ~
!define /math NOT_SF_SELECTED_OR_RO ${NOT_SF_SELECTED} & ${NOT_SF_RO}

!macro RestoreSectionState SectionIndex Variable
	Push $0
	SectionGetFlags ${SectionIndex} $0
	IntOp $0 $0 & ${NOT_SF_SELECTED_OR_RO}
	IntOp $0 $0 | ${Variable}
	SectionSetFlags ${SectionIndex} $0
	Pop $0
!macroend

!macro SectionUngroup SectionIndex
	Push $0
	Push $1
	SectionGetFlags ${SectionIndex} $0
	IntOp $0 $0 & ${NOT_SF_SECGRP}
	IntOp $1 $0 & ${SF_PSELECTED}
	${IfNot} $1 == 0
		IntOp $0 $0 & ${NOT_SF_PSELECTED}
		IntOp $0 $0 | ${SF_SELECTED}
	${EndIf}
	SectionSetFlags ${SectionIndex} $0
	Pop $1
	Pop $0
!macroend

!macro SectionRegroup SectionIndex
	!insertmacro SetSectionFlag ${SectionIndex} ${SF_SECGRP}
!macroend

!macro COMPONENTS_PAGE_FUNCTIONS

Function PageComponentsOnPre
	
	${If} $ArxFatalisLocation == ""
		!insertmacro RestoreSectionState ${PatchInstall} ${SF_RO}
		!insertmacro RestoreSectionState ${SeparateInstall} ${SF_SELECTED_AND_RO}
	${Else}
		!insertmacro RestoreSectionState ${PatchInstall} $SecPatchInstall
		!insertmacro RestoreSectionState ${SeparateInstall} $SecSeparateInstall
	${EndIf}
	
	; Required so the SectionUngroup hack does not become apparent when leaving the page and coming back:
	; The sections need to be grouped between OnPre and OnShow to show up as gouped in the list.
	!insertmacro SectionRegroup ${SeparateInstall}
	!insertmacro SectionRegroup ${PatchInstall}
	
FunctionEnd

Function PageComponentsOnShow
	
	SysCompImg::SetThemed
	
	; Hack to work around NSIS' behavior when selecting a section group or subsections:
	; This will cause sections to show up as grouped but be selectable independently.
	!insertmacro SectionUngroup ${PatchInstall}
	!insertmacro SectionUngroup ${SeparateInstall}
	
	Call RestorePatchInstallState
	Call RestoreSeparateInstallState
	
	Call PageInstallModeIsInstall
	Call SetNextButtonToInstall
	
FunctionEnd

Function RestorePatchInstallState
	${If} $SecPatchInstall != 0
	${AndIf} $ArxFatalisLocation != ""
		!insertmacro SetSectionFlag ${PatchInstall} ${SF_EXPAND}
	${Else}
		!insertmacro ClearSectionFlag ${PatchInstall} ${SF_EXPAND}
	${EndIf}
FunctionEnd

Function SaveSeparateInstallState
	${If} $SecSeparateInstall != 0
	${OrIf} $ArxFatalisLocation == ""
		${If} $ArxFatalisLocation != ""
			!insertmacro SaveSectionState ${CopyData} $SecCopyData
		${EndIf}
		!insertmacro SaveSectionState ${StartMenu} $SecStartMenu
		!insertmacro SaveSectionState ${Desktop} $SecDesktop
		!insertmacro SaveSectionState ${QuickLaunch} $SecQuickLaunch
	${EndIf}
FunctionEnd

Function RestoreSeparateInstallState
	${If} $SecSeparateInstall != 0
	${OrIf} $ArxFatalisLocation == ""
		${If} $ArxFatalisLocation != ""
			!insertmacro RestoreSectionState ${CopyData} $SecCopyData
		${Else}
			!insertmacro RestoreSectionState ${CopyData} ${SF_RO}
		${EndIf}
		!insertmacro RestoreSectionState ${StartMenu} $SecStartMenu
		!insertmacro RestoreSectionState ${Desktop} $SecDesktop
		!insertmacro RestoreSectionState ${QuickLaunch} $SecQuickLaunch
		!insertmacro SetSectionFlag ${SeparateInstall} ${SF_EXPAND}
	${Else}
		!insertmacro ClearSectionFlag ${SeparateInstall} ${SF_EXPAND}
		!insertmacro RestoreSectionState ${CopyData} ${SF_RO}
		!insertmacro RestoreSectionState ${StartMenu} ${SF_RO}
		!insertmacro RestoreSectionState ${Desktop} ${SF_RO}
		!insertmacro RestoreSectionState ${QuickLaunch} ${SF_RO}
	${EndIf}
FunctionEnd

Function .onSelChange
	
	Push $0 ; Index of clicked section
	Push $1
	
	Call SaveSeparateInstallState
	
	${If} $ArxFatalisLocation != ""
		
		; PatchInstall and SeparateInstall are mutually exclusive
		${If} $0 == ${PatchInstall}
			${If} ${SectionIsSelected} ${PatchInstall}
				!insertmacro UnselectSection ${SeparateInstall}
			${Else}
				!insertmacro SelectSection ${SeparateInstall}
			${EndIf}
		${Else}
			${If} ${SectionIsSelected} ${SeparateInstall}
				!insertmacro UnselectSection ${PatchInstall}
			${Else}
				!insertmacro SelectSection ${PatchInstall}
			${EndIf}
		${EndIf}
		
		SectionGetFlags ${PatchInstall} $1
		IntOp $1 $1 & ${SF_SELECTED}
		${If} $1 != $SecPatchInstall
			StrCpy $SecPatchInstall $1
			Call RestorePatchInstallState
		${EndIf}
		
		SectionGetFlags ${SeparateInstall} $1
		IntOp $1 $1 & ${SF_SELECTED}
		${If} $1 != $SecSeparateInstall
			StrCpy $SecSeparateInstall $1
			Call RestoreSeparateInstallState
		${EndIf}
		
	${EndIf}
	
	Call PageInstallModeIsInstall
	Call SetNextButtonToInstall
	
	Pop $1
	Pop $0
	
FunctionEnd

!macroend
