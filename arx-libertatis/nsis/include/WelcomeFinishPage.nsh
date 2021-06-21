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
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "ArxFatalisData.nsh"

!macro WELCOME_PAGE
!ifndef MUI_WELCOMEFINISHPAGE_BITMAP
!define MUI_WELCOMEFINISHPAGE_BITMAP "data\Side.bmp"
!endif
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageWelcomeOnShow
!insertmacro MUI_PAGE_WELCOME
!macroend

!macro FINISH_PAGE
!ifndef MUI_WELCOMEFINISHPAGE_BITMAP
!define MUI_WELCOMEFINISHPAGE_BITMAP "data\Side.bmp"
!endif
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageFinishOnShow
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION PageFinishOnRun
!insertmacro MUI_PAGE_FINISH
!macroend

!macro WELCOME_FINISH_PAGE_RESERVE
	ReserveFile data\Side_2x.bmp
!macroend

!macro WELCOME_FINISH_PAGE_INIT
	InitPluginsDir
	File /oname=$PLUGINSDIR\Side_2x.bmp data\Side_2x.bmp
!macroend

Function PageWelcomeFinishOnShow
	
	Exch $0 ; $mui.WelcomePage.Image.Bitmap / $mui.FinishPage.Image.Bitmap
	Exch
	Exch $1 ; $mui.WelcomePage.Image / $mui.FinishPage.Image
	Push $2
	Push $3
	Push $4
	
	; Use a higner resolution image on HiDPI screens
	; Ideally we'd always use the higher-resolution image but NSIS only does nearest-neighbor scaling
	Push $0
	SysCompImg::GetSysDpi
	StrCpy $2 $0
	Pop $0
	${If} $2 U<= 0
		StrCpy $2 96
	${EndIf}
	${If} $2 > 96
		${NSD_FreeImage} $0
		${NSD_SetStretchedBitmap} $1 "$PLUGINSDIR\Side_2x.bmp" $0
	${EndIf}
	IntOp $2 $2 / 15
	
	CreateFont $3 "$(^Font)" "$(^FontSize)" "700"
	
	; Website URL
	${NSD_CreateLabel} $2 170u 110u 10u "<?= $project_url ?>"
	Pop $4
	${NSD_AddStyle} $4 ${SS_CENTER}
	SetCtlColors $4 "774400" transparent
	SendMessage $4 ${WM_SETFONT} $3 1
	${NSD_OnClick} $4 OnClickProjectWebsite
	
	<? if($is_snapshot): ?>
	
	; Snapshot version number
	${NSD_CreateLabel} $2 100u 110u 10u "<?= $version ?>"
	Pop $4
	${NSD_AddStyle} $4 ${SS_CENTER}
	SetCtlColors $4 "774400" transparent
	SendMessage $4 ${WM_SETFONT} $3 1
	${NSD_OnClick} $4 OnClickProjectWebsite
	
	; Version type
	<? if($is_release_candidate): ?>
	${NSD_CreateLabel} $2 115u 110u 10u "($(ARX_RELEASE_CANDIDATE))"
	<? else: ?>
	${NSD_CreateLabel} $2 115u 110u 10u "($(ARX_DEVELOPMENT_SNAPSHOT))"
	<? endif; ?>
	Pop $4
	${NSD_AddStyle} $4 ${SS_CENTER}
	SetCtlColors $4 "774400" transparent
	SendMessage $4 ${WM_SETFONT} $3 1
	${NSD_OnClick} $4 OnClickProjectWebsite
	
	; Version suffix
	<? if($version_suffix != ''): ?>
	${NSD_CreateLabel} $2 130u 110u 10u "<?= $version_suffix ?>"
	Pop $4
	${NSD_AddStyle} $4 ${SS_CENTER}
	SetCtlColors $4 "774400" transparent
	SendMessage $4 ${WM_SETFONT} $3 1
	${NSD_OnClick} $4 OnClickProjectWebsite
	<? endif; ?>
	
	; Snapshot warning text
	${NSD_CreateLabel} 120u 130u 195u 60u "$(ARX_SNAPSHOT_WARNING) ${ARX_BUG_URL}"
	Pop $4
	SetCtlColors $4 "885500" "FFFFFF"
	SendMessage $4 ${WM_SETFONT} $3 1
	
	<? else: ?>
	
	; Version codename
	<? if($version_codename != ''): ?>
	${NSD_CreateLabel} $2 115u 110u 10u '"<?= $version_codename ?>"'
	Pop $4
	${NSD_AddStyle} $4 ${SS_CENTER}
	SetCtlColors $4 "774400" transparent
	SendMessage $4 ${WM_SETFONT} $3 1
	${NSD_OnClick} $4 OnClickProjectWebsite
	<? endif; ?>
	
	CreateFont $3 "Arial Black" "24" "500"
	
	; Large version number
	${NSD_CreateLabel} $2 90u 110u 30u "<?= $version ?>"
	Pop $4
	${NSD_AddStyle} $4 ${SS_CENTER}
	SetCtlColors $4 "774400" transparent
	SendMessage $4 ${WM_SETFONT} $3 1
	${NSD_OnClick} $4 OnClickProjectWebsite
	
	<? endif; ?>
	
	; Move side image a bit and put it behind everything else
	System::Call 'USER32::SetWindowPos(ir1, i1, ir2, i0, i0, i0, i1)'
	${NSD_OnClick} $1 OnClickProjectWebsite
	
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

!macro PageWelcomeFinishOnShow Image Bitmap
	Push "${Image}"
	Push "${Bitmap}"
	Call PageWelcomeFinishOnShow
	Pop ${Bitmap}
!macroend

!define PageWelcomeFinishOnShow '!insertmacro PageWelcomeFinishOnShow'

Function OnClickProjectWebsite
	
	ExecShell "open" "<?= $project_url ?>" SW_SHOWNORMAL
	
FunctionEnd

!macro WELCOME_FINISH_PAGE_FUNCTIONS

Function PageWelcomeOnShow
	
	${PageWelcomeFinishOnShow} $mui.WelcomePage.Image $mui.WelcomePage.Image.Bitmap
	
FunctionEnd

Function PageFinishOnShow
	
	${PageWelcomeFinishOnShow} $mui.FinishPage.Image $mui.FinishPage.Image.Bitmap
	
	${If} $ArxFatalisLocation == ""
		${NSD_Uncheck} $mui.FinishPage.Run
	${EndIf}
	
FunctionEnd

Function PageFinishOnRun
	
	${LaunchArxFatalis} "$INSTDIR"
	
FunctionEnd

!macroend
