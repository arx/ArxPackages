;------------------------------------------------------------------------------
; Copyright 2011-2021 Arx Libertatis Team (see the AUTHORS file)
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

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "LoadIcon.nsh"
!include "PathUtil.nsh"
!include "ArxFatalisData.nsh"

Var ArxFatalisLocationInput
Var ArxFatalisLocationIcon
Var IconQuestion
Var IconInfo
Var IconWarning
Var IconError
Var ArxFatalisLocationLabel
Var ArxFatalisLocationNext
Var ArxFatalisLocation
Var ArxFatalisFileCount
Var ArxFatalisType

!macro ARX_FATALIS_LOCATION_PAGE
PageEx custom
	PageCallbacks PageArxFatalisLocationOnCreate PageArxFatalisLocationOnLeave
PageExEnd
!macroend

!macro ARX_FATALIS_LOCATION_PAGE_INIT
	Push $0
	${List.Count} $0 ArxFatalisLocations
	${IfNot} $0 == 0
		${List.Get} $ArxFatalisLocation ArxFatalisLocations 0
	${EndIf}
	Pop $0
!macroend

!macro ARX_FATALIS_LOCATION_PAGE_FUNCTIONS

Function PageArxFatalisLocationOnCreate
	
	Push $0
	Push $1
	Push $2
	
	!insertmacro MUI_HEADER_TEXT "$(ARX_FATALIS_LOCATION_PAGE_TITLE)" "$(ARX_FATALIS_LOCATION_PAGE_SUBTITLE)"
	
	nsDialogs::Create 1018
	Pop $0
	
	GetDlgItem $ArxFatalisLocationNext $HWNDPARENT 1
	
	${NSD_CreateLabel} 0u 0u 100% 60u "$(ARX_FATALIS_LOCATION_PAGE_DESCRIPTION)"
	Pop $0
	
	${NSD_CreateGroupBox} 0u 70u 100% 35u "$(ARX_FATALIS_LOCATION_LABEL)"
	Pop $0
	
	${List.Count} $0 ArxFatalisLocations
	${If} $0 == 0
		${NSD_CreateDirRequest} 10u 85u 210u 12u ""
		Pop $ArxFatalisLocationInput
	${Else}
		${NSD_CreateComboBox} 10u 85u 210u 12u ""
		Pop $ArxFatalisLocationInput
		StrCpy $1 0
		${DoWhile} $1 < $0
			${List.Get} $2 ArxFatalisLocations $1
			${NSD_CB_AddString} $ArxFatalisLocationInput "$2"
			IntOp $1 $1 + 1
		${Loop}
	${EndIf}
	${NSD_SetText} $ArxFatalisLocationInput "$ArxFatalisLocation"
	${NSD_OnChange} $ArxFatalisLocationInput PageArxFatalisLocationOnChange
	
	${NSD_CreateBrowseButton} 228u 83u 60u 15u "$(^BrowseBtn)"
	Pop $0
	${NSD_OnClick} $0 PageArxFatalisLocationOnBrowse
	
	${NSD_CreateIcon} 0u 114u 5u 5u ""
	Pop $ArxFatalisLocationIcon
	${LoadSmallIcon} ${IDI_QUESTION} $IconQuestion
	${LoadSmallIcon} ${IDI_INFORMATION} $IconInfo
	${LoadSmallIcon} ${IDI_WARNING} $IconWarning
	${LoadSmallIcon} ${IDI_ERROR} $IconError
	SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconQuestion
	
	${NSD_CreateLabel} 6% 115u 94% 20u "$(ARX_FATALIS_LOCATION_WAIT)"
	Pop $ArxFatalisLocationLabel
	
	StrCpy $ArxFatalisLocation ""
	${NSD_CreateTimer} PageArxFatalisLocationUpdate 1
	
	nsDialogs::Show
	
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

Function PageArxFatalisLocationOnChange
	
	Call PageArxFatalisLocationUpdate
	
	; NSD_GetText returns the previous text here when the change was done using the combobox drop down menu
	; because the text is not yet updated when the CBN_SELCHANGE event fires.
	; We coul try to detect if the selection changes and then get the text of the selected item instead,
	; but editing does not realiably clear the selection so we won't see if the old item is selected again.
	; Instead, we must check the text again *after* the CBN_SELCHANGE event has been processed.
	${NSD_CreateTimer} PageArxFatalisLocationUpdate 1
	
FunctionEnd

; Check Arx Fatalis install at the selected location in $ArxFatalisLocationInput
; Updates icon, label, $ArxFatalisLocation and $ArxFatalisType
Function PageArxFatalisLocationUpdate
	
	Push $0
	Push $1
	
	${NSD_KillTimer} PageArxFatalisLocationUpdate
	
	${NSD_GetText} $ArxFatalisLocationInput $0
	
	${If} $0 == ""
		SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconWarning
		${NSD_SetText} $ArxFatalisLocationLabel "$(ARX_FATALIS_LOCATION_EMPTY)"
		StrCpy $ArxFatalisLocation ""
		StrCpy $ArxFatalisType ""
		EnableWindow $ArxFatalisLocationNext 1
		Return
	${EndIf}
	
	${IfNot} ${FileExists} "$0\*.*"
		SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconError
		${NSD_SetText} $ArxFatalisLocationLabel "$(ARX_FATALIS_LOCATION_NODIR)"
		StrCpy $ArxFatalisLocation "$0"
		StrCpy $ArxFatalisType ""
		EnableWindow $ArxFatalisLocationNext 0
		Return
	${EndIf}
	
	${NormalizePath} "$0" $0
	
	${If} $0 == $ArxFatalisLocation
		StrCpy $ArxFatalisLocation $0
		Return
	${EndIf}
	
	StrCpy $ArxFatalisLocation $0
	
	SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconQuestion
	${NSD_SetText} $ArxFatalisLocationLabel "$(ARX_FATALIS_LOCATION_WAIT)"
	
	${IdentifyArxFatalisData} "$ArxFatalisLocation" $ArxFatalisType
	
	${If} $ArxFatalisType == ""
		SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconError
		${NSD_SetText} $ArxFatalisLocationLabel "$(ARX_FATALIS_LOCATION_NODATA)"
		EnableWindow $ArxFatalisLocationNext 0
		Return
	${EndIf}
	
	EnableWindow $ArxFatalisLocationNext 1
	
	${GetArxFatalisLocationInfo} "$ArxFatalisLocation" $0 $1
	
	${If} $ArxFatalisType == "patched"
		SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconInfo
	${ElseIf} $ArxFatalisType == "demo"
	${AndIf} $1 == ""
		SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconInfo
	${Else}
		SendMessage $ArxFatalisLocationIcon ${STM_SETIMAGE} ${IMAGE_ICON} $IconWarning
	${EndIf}
	
	${Switch} $1
		
		${Case} "gog"
			StrCpy $0 "$(ARX_FATALIS_LOCATION_GOG)"
			${Break}
		
		${Case} "steam"
			StrCpy $0 "$(ARX_FATALIS_LOCATION_STEAM)"
			${Break}
		
		${Case} "bethesda"
			StrCpy $0 "$(ARX_FATALIS_LOCATION_BETHESDA)"
			${Break}
		
		${Case} "windows"
			StrCpy $0 "$(ARX_FATALIS_LOCATION_WINDOWS)"
			${Break}
		
		${Default}
			StrCpy $0 ""
		
	${EndSwitch}
	
	${Switch} $ArxFatalisType
		
		${Case} "demo"
			StrCpy $1 "$(ARX_FATALIS_LOCATION_DEMO)"
			${Break}
		
		${Case} "patched"
		${Case} "unpatched"
			StrCpy $1 ""
			${Break}
		
		${Default}
			StrCpy $1 "$(ARX_FATALIS_LOCATION_UNKNOWN)"
			${Break}
		
	${EndSwitch}
	
	${If} $0 == ""
		StrCpy $0 "$1"
	${ElseIfNot} $1 == ""
		StrCpy $0 "$0 ($1)"
	${EndIf}
	
	${If} $0 == ""
		StrCpy $0 "$(ARX_FATALIS_LOCATION_RETAIL)"
	${EndIf}
	
	${IfNot} $ArxFatalisType == "patched"
	${AndIfNot} $ArxFatalisType == "demo"
		StrCpy $0 "$0$\n$(ARX_FATALIS_LOCATION_UNPATCHED)"
	${EndIf}
	
	${NSD_SetText} $ArxFatalisLocationLabel "$(ARX_FATALIS_LOCATION_FOUND) $0"
	
	Pop $1
	Pop $0
	
FunctionEnd

Function PageArxFatalisLocationOnBrowse
	
	Push $0
	
	nsDialogs::SelectFolderDialog "$(ARX_FATALIS_LOCATION_BROWSE_TITLE)" "$ArxFatalisLocation"
	Pop $0
	${If} $0 != error
		${NSD_SetText} $ArxFatalisLocationInput "$0"
		Call PageArxFatalisLocationOnChange
	${EndIf}
	
	Pop $0
	
FunctionEnd

Function PageArxFatalisLocationOnLeave
	
	Call PageArxFatalisLocationUpdate
	
	${If} $ArxFatalisLocation == ""
		MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(ARX_FATALIS_LOCATION_EMPTY_CONTINUE)" IDNO abort
	${ElseIf} $ArxFatalisType == ""
		Abort
	${ElseIfNot} $ArxFatalisType == "patched"
	${AndIfNot} $ArxFatalisType == "demo"
		MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(ARX_FATALIS_LOCATION_UNPATCHED_CONTINUE)" IDNO abort
	${EndIf}
	
	Push $0
	${If} $ArxFatalisLocation != ""
		${GetArxFatalisDataSize} "$ArxFatalisLocation" $0 $ArxFatalisFileCount
	${Else}
		StrCpy $0 0
	${EndIf}
	SectionSetSize ${CopyData} $0
	Pop $0
	
	Return
	
abort:
	Abort
	
FunctionEnd

!macroend
