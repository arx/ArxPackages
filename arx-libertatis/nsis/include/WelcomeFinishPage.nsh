
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

!macro WELCOME_PAGE
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageWelcomeFinishOnShow
!insertmacro MUI_PAGE_WELCOME
!macroend

!macro FINISH_PAGE
!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageWelcomeFinishOnShow
!define MUI_FINISHPAGE_RUN "$INSTDIR\arx.exe"
!insertmacro MUI_PAGE_FINISH
!macroend

!macro WELCOME_FINISH_PAGE_RESERVE
ReserveFile data\Side_2x.bmp
!macroend

!macro WELCOME_FINISH_PAGE_INIT
File /oname=$PLUGINSDIR\Side_2x.bmp data\Side_2x.bmp
!macroend

!macro WELCOME_FINISH_PAGE_FUNCTIONS

Function PageWelcomeFinishOnShow
	
	; Use a higner resolution image on HiDPI screens
	; Ideally we'd always use the higher-resolution image but NSIS only does nearest-neighbor scaling
	System::Call USER32::GetDpiForSystem()i.r0
	${If} $0 U<= 0
		System::Call USER32::GetDC(i0)i.r1
		System::Call GDI32::GetDeviceCaps(ir1,i88)i.r0
		System::Call USER32::ReleaseDC(i0,ir1)
	${EndIf}
	${If} $0 U<= 0
		StrCpy $0 96
	${Endif}
	IntOp $1 $0 / 15
	${If} $0 > 96
		${NSD_FreeImage} $mui.WelcomePage.Image.Bitmap
		${NSD_SetStretchedBitmap} $mui.WelcomePage.Image "$PLUGINSDIR\Side_2x.bmp" $mui.WelcomePage.Image.Bitmap
		${NSD_FreeImage} $mui.FinishPage.Image.Bitmap
		${NSD_SetStretchedBitmap} $mui.FinishPage.Image "$PLUGINSDIR\Side_2x.bmp" $mui.FinishPage.Image.Bitmap
	${Endif}
	
	CreateFont $0 "$(^Font)" "$(^FontSize)" "700"
	
	<? if($is_snapshot): ?>
	
	; Snapshot version number
	${NSD_CreateLabel} $1 100u 110u 10u "<?= $version ?>"
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
	${NSD_OnClick} $R0 OnClickProjectWebsite
	
	; Version suffix
	<? if($version_suffix != ''): ?>
	${NSD_CreateLabel} $1 115u 110u 10u "<?= $version_suffix ?>"
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
	${NSD_OnClick} $R0 OnClickProjectWebsite
	<? endif; ?>
	
	; Snapshot warning text
	${NSD_CreateLabel} 120u 130u 195u 60u "$(ARX_SNAPSHOT_WARNING) https://arx.vg/bug"
	Pop $R0
	SetCtlColors $R0 "885500" "FFFFFF"
	SendMessage $R0 ${WM_SETFONT} $0 1
	
	<? else: ?>
	
	; Large version number
	${NSD_CreateLabel} $1 90u 110u 30u "<?= $version ?>"
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	CreateFont $2 "Arial Black" "24" "500"
	SendMessage $R0 ${WM_SETFONT} $2 1
	${NSD_OnClick} $R0 OnClickProjectWebsite
	
	; Version codename
	<? if($version_codename != ''): ?>
	${NSD_CreateLabel} $1 115u 110u 10u '"<?= $version_codename ?>"'
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
	${NSD_OnClick} $R0 OnClickProjectWebsite
	<? endif; ?>
	
	<? endif; ?>
	
	; Website URL
	${NSD_CreateLabel} $1 170u 110u 10u "<?= $project_url ?>"
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
	${NSD_OnClick} $R0 OnClickProjectWebsite
	
	; Move side image a bit and put it behind everything else
	System::Call 'USER32::SetWindowPos(i $mui.WelcomePage.Image, i1, i $1, i0, i0, i0, i1)'
	System::Call 'USER32::SetWindowPos(i $mui.FinishPage.Image, i1, i $1, i0, i0, i0, i1)'
	
	${NSD_OnClick} $mui.WelcomePage.Image OnClickProjectWebsite
	${NSD_OnClick} $mui.FinishPage.Image OnClickProjectWebsite
	
FunctionEnd

Function OnClickProjectWebsite
	ExecShell "open" "<?= $project_url ?>" SW_SHOWNORMAL
FunctionEnd

!macroend
