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
!include "SpaceRequired.nsh"

Var SpaceRequired
Var SpaceRequiredDrive

!macro DIRECTORY_PAGE
!define MUI_DIRECTORYPAGE_VERIFYONLEAVE
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
	
	${If} $ExistingInstallLocation != ""
		${SpaceRequiredReplace} $mui.DirectoryPage.SpaceRequired
		StrCpy $SpaceRequiredDrive ""
		Push "$INSTDIR"
		Call UpdateSpaceRequiredDrive
		${SpaceRequired} $mui.DirectoryPage.SpaceRequired $SpaceRequired
	${EndIf}
	
FunctionEnd

Function .onVerifyInstDir
	
	Push $0
	
	${NormalizePath} "$INSTDIR" $0
	
	${If} $ExistingInstallLocation != ""
	${AndIf} $0 != ""
		Push "$0"
		Call UpdateSpaceRequiredDrive
		${SpaceRequired} $mui.DirectoryPage.SpaceRequired $SpaceRequired
	${EndIf}
	
	${If} $0 == $ArxFatalisLocation
		Pop $0
		Abort
	${EndIf}
	
	Pop $0
	
FunctionEnd

Function UpdateSpaceRequiredDrive
	
	Exch $0
	Push $1
	
	StrCpy $0 "$0" 2
	${If} $0 != $SpaceRequiredDrive
		StrCpy $SpaceRequiredDrive "$0"
		
		${Map.Create} SpaceRequiredDriveOverrides
		${Map.Set} SpaceRequiredDriveOverrides ${Main} 0
		${Map.Set} SpaceRequiredDriveOverrides ${PatchInstall} ${MAIN_SECTION_SIZE}
		${Map.Set} SpaceRequiredDriveOverrides ${SeparateInstall} ${MAIN_SECTION_SIZE}
		
		; Filter sections that are not on the target drive
		!insertmacro UpdateSpaceRequiredDriveOverride "$SMPROGRAMS" ${StartMenu}
		StrCpy $0 "$StartMenuFolder" 1
		${If} $0 == ">"
			${Map.Set} SpaceRequiredDriveOverrides ${StartMenu} 0
		${EndIf}
		!insertmacro UpdateSpaceRequiredDriveOverride "$DESKTOP" ${Desktop}
		!insertmacro UpdateSpaceRequiredDriveOverride "$QUICKLAUNCH" ${QuickLaunch}
		${If} $ExistingInstallLocation != ""
			${UninstallLogGetOldSize} "$ExistingInstallLocation\${UninstallLog}" "$SpaceRequiredDrive" $1
			StrCpy $0 "$ExistingInstallLocation" 2
			${If} $0 == $SpaceRequiredDrive
				${GetFileSize} "$ExistingInstallLocation\uninstall.exe" $0
				IntOp $1 $1 - $0
			${EndIf}
			IntOp $1 0 - $1
			${Map.Set} SpaceRequiredDriveOverrides ${Cleanup} $1
		${EndIf}
		
		${SpaceRequiredGet} SpaceRequiredDriveOverrides $SpaceRequired
		${If} $SpaceRequired < 0
			StrCpy $SpaceRequired 0
		${EndIf}
		
		${Map.Destroy} SpaceRequiredDriveOverrides
		
	${EndIf}
	
	Pop $1
	Pop $0
	
FunctionEnd

!macroend

!macro UpdateSpaceRequiredDriveOverride Variable SectionIndex
	StrCpy $0 "${Variable}" 2
	${If} $0 != $SpaceRequiredDrive
		${Map.Set} SpaceRequiredDriveOverrides ${SectionIndex} 0
	${EndIf}
!macroend
