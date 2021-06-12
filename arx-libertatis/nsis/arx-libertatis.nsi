;------------------------------------------------------------------------------
; Copyright 2011-2012 Arx Libertatis Team (see the AUTHORS file)
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

;------------------------------------------------------------------------------
; Arx Libertatis installer script for Windows 32/64 bits
;
; To build an installer you'll need NSIS and the md5 plugin
;	* http://nsis.sourceforge.net
;	* http://nsis.sourceforge.net/MD5_plugin
;------------------------------------------------------------------------------

Unicode True
SetCompressor /SOLID LZMA
ManifestDPIAware True
ManifestLongPathAware True

!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "Software\ArxLibertatis"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "InstallLocation"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "Software\ArxLibertatis"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "InstallLocation"
!define MULTIUSER_INSTALLMODE_INSTDIR "Arx Libertatis"

!define MULTIUSER_USE_PROGRAMFILES64

!addincludedir include

!include "MultiUser.nsh"
!include "Winver.nsh"
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

!include "UninstallLog.nsh"
!include "ArxFatalisData.nsh"

;------------------------------------------------------------------------------
;General

!define Icon "source\data\icons\arx-libertatis.ico"

Name          "Arx Libertatis"
Caption       "Arx Libertatis <?= $version ?> $(ARX_TITLE_SUFFIX)"
OutFile       "<?= $outfile ?>"
InstallDir    "$PROGRAMFILES\Arx Libertatis"
BrandingText  " "

;------------------------------------------------------------------------------
;Variables

Var StartMenuFolder
Var ArxFatalisInstallDir
Var ArxFatalisLanguage

;------------------------------------------------------------------------------
;Version Info

!makensis "GetVersion.nsi"
!system "GetVersion.exe build\arx.exe"
!include "Version.nsh"

VIAddVersionKey  "CompanyName"     "${CompanyName}"
VIAddVersionKey  "FileDescription" "${ProductName} installer"
VIAddVersionKey  "FileVersion"     "${ProductVersion}"
VIAddVersionKey  "ProductName"     "${ProductName}"
VIAddVersionKey  "ProductVersion"  "${ProductVersion}"
VIAddVersionKey  "LegalCopyright"  "${LegalCopyright}"
VIProductVersion "${Version}"
VIFileVersion "${Version}"

;------------------------------------------------------------------------------
;Interface Settings

!define MUI_ICON "${Icon}"
!define MUI_UNICON "${Icon}"
!define MUI_WELCOMEFINISHPAGE_BITMAP "data\Side.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "data\Side.bmp"
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_NODESC 

;------------------------------------------------------------------------------
;Language Selection Dialog Settings

;!define MUI_LANGDLL_ALLLANGUAGES

;Remember the installer language
!define MUI_LANGDLL_REGISTRY_ROOT "SHCTX" 
!define MUI_LANGDLL_REGISTRY_KEY "Software\ArxLibertatis" 
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;------------------------------------------------------------------------------
;Pages

!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageWelcomeFinishOnShow
!insertmacro MUI_PAGE_WELCOME
!undef MUI_PAGE_CUSTOMFUNCTION_SHOW

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "SHCTX" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ArxLibertatis" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Arx Libertatis"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!define MUI_DIRECTORYPAGE_VARIABLE          $ArxFatalisInstallDir
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION  "Arx Fatalis Location"
!define MUI_DIRECTORYPAGE_TEXT_TOP          "In order to play Arx Libertatis, you need to have the original data from Arx Fatalis. You can also play using the demo data. Please specify the location of the original Arx Fatalis installation where *.pak files can be found. Those files (along with a few others) will be copied to your Arx Libertatis install directory. If you don't have the Arx Fatalis data yet, leave this field empty. You can always copy the data files later."
!define MUI_PAGE_HEADER_TEXT                "Specify Data Location"
!define MUI_PAGE_HEADER_SUBTEXT             "Please specify the location of the original Arx Fatalis data"
!define MUI_DIRECTORYPAGE_VERIFYONLEAVE
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE       DetectArx
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_NOAUTOCLOSE

!define MUI_PAGE_CUSTOMFUNCTION_SHOW PageWelcomeFinishOnShow
!define MUI_FINISHPAGE_RUN "$INSTDIR\arx.exe"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;------------------------------------------------------------------------------
;Languages

!macro AddLanguage Language
	!insertmacro MUI_LANGUAGE "${Language}"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT "lang\${Language}.nsh" "lang\English.nsh"
!macroend

!insertmacro AddLanguage "English"
!insertmacro AddLanguage "French"
!insertmacro AddLanguage "German"
!insertmacro AddLanguage "Spanish"
!insertmacro AddLanguage "TradChinese"
!insertmacro AddLanguage "Japanese"
;!insertmacro AddLanguage "Korean"
!insertmacro AddLanguage "Italian"
!insertmacro AddLanguage "Russian"
;!insertmacro AddLanguage "Portuguese"
;!insertmacro AddLanguage "Polish"
;!insertmacro AddLanguage "Turkish"

;Reserve Files

!insertmacro MUI_RESERVEFILE_LANGDLL

;------------------------------------------------------------------------------
Section "Arx Libertatis"
	
	SetDetailsPrint listonly
	
	InitPluginsDir
	SectionIn RO
	
	; Set output path to the installation directory.
	SetOutPath "$INSTDIR"
	
	SetDetailsPrint both
	DetailPrint "Installing Arx Libertatis binaries..."
	SetDetailsPrint listonly
	<?
	$dir_iterator = new RecursiveDirectoryIterator("$outdir/build");
	$iterator = new RecursiveIteratorIterator($dir_iterator, RecursiveIteratorIterator::SELF_FIRST);
	foreach($iterator as $file):
		if(str_ends_with($file->getPathname(), '/.') || str_ends_with($file->getPathname(), '/..')) {
			continue;
		}
		$filename = str_replace('/', '\\', str_replace("$outdir/build/", '', $file->getPathname()));
		if($file->getType() == 'dir'):
	?>
	${CreateDirectory} "$OUTDIR\<?= $filename ?>"
	<?
		else:
	?>
	${File} "build" "<?= $filename ?>"
	<?
		endif;
	endforeach;
	?>
	
	;----------------------------------------------------------------------------
	; Arx Fatalis data copy
	;----------------------------------------------------------------------------
	${If} $ArxFatalisInstallDir != ""
		SetDetailsPrint both
		DetailPrint "Copying Arx Fatalis data files..."
		SetDetailsPrint listonly
		${CopyArxDataFiles} $ArxFatalisInstallDir $ArxFatalisLanguage
	${EndIf}
	
	;----------------------------------------------------------------------------
	; VC++ 2010 Redistributable
	;----------------------------------------------------------------------------
	;SetDetailsPrint both
	;DetailPrint "Installing VC++ 2010 Redistributable..."
	;SetDetailsPrint listonly
	;File /oname=$PLUGINSDIR\vcredist_${ARCH}.exe vcredist\vcredist_${ARCH}.exe
	;ExecWait '"$PLUGINSDIR\vcredist_${ARCH}.exe" /q /norestart' $1
	;${If} $1 == 0
	;	; Success!
	;${ElseIf} $1 == 3010
	;	; Success, but reboot required
	;	SetRebootFlag true
	;${ElseIf} $1 == 5100
	;	; Later version already installed
	;${Else}
	;	; Failed!
	;	MessageBox MB_OK|MB_ICONSTOP "Visual C++ 2010 Redistributable installation failed with error $1!"
	;	Abort
	;${EndIf}

	;----------------------------------------------------------------------------
	; Create uninstaller
	;----------------------------------------------------------------------------
	${WriteUninstaller} "$INSTDIR\uninstall.exe"

	;----------------------------------------------------------------------------
	; Registry fun
	;----------------------------------------------------------------------------
	; Store installation folder
	WriteRegStr SHCTX "Software\ArxLibertatis" "InstallLocation" $INSTDIR
	WriteRegStr SHCTX "Software\ArxLibertatis" "DataDir" $INSTDIR

	; Add uninstall information
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayName" "Arx Libertatis" 
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayIcon" "$\"$INSTDIR\arx.exe$\""
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "URLInfoAbout" "https://arx-libertatis.org/"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayVersion" "<?= $version ?>"
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoModify" 1
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoRepair" 1
	
	${If} $ArxFatalisInstallDir != ""
		; If an error occured in the data copy, display a message
		Call ShowDataErrorMessageBox
	${EndIf}

	IfRebootFlag 0 noreboot
	MessageBox MB_YESNO|MB_ICONQUESTION "A reboot is required to finish the installation. Do you wish to reboot now?" IDNO noreboot
		Reboot

noreboot:

SectionEnd

Section -StartMenu
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		${CreateDirectory} "$SMPROGRAMS\$StartMenuFolder"
		${CreateShortCut} "$SMPROGRAMS\$StartMenuFolder\Play Arx Libertatis.lnk" "$INSTDIR\arx.exe"
		${CreateShortCut} "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Create a desktop icon" Desktop
	${CreateShortCut} "$DESKTOP\Arx Libertatis.lnk" "$INSTDIR\arx.exe"
SectionEnd

Section "Create a Quick Launch icon" QuickLaunch
	${CreateShortCut} "$QUICKLAUNCH\Arx Libertatis.lnk" "$INSTDIR\arx.exe"
SectionEnd

;------------------------------------------------------------------------------
;Installer Functions

Function .onInit
	
	!insertmacro MUI_LANGDLL_DISPLAY
	
	File /oname=$PLUGINSDIR\Side_2x.bmp data\Side_2x.bmp
	
	; Check for >= Windows XP SP2
	${IfNot} ${AtLeastWinVista}
		${IfNot} ${IsWinXP}
		${OrIfNot} ${AtLeastServicePack} 2
			MessageBox MB_OK|MB_ICONEXCLAMATION "Arx Libertatis requires Windows XP Service Pack 2 or later."
		${EndIf}
	${EndIf}
	
	SetRegView 64
	
	!insertmacro MULTIUSER_INIT
	
	Call FindArxInstall
	StrCpy $ArxFatalisInstallDir $0
	
FunctionEnd

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
	
	; Version suffix
	<? if($version_suffix != ''): ?>
	${NSD_CreateLabel} $1 115u 110u 10u "<?= $version_suffix ?>"
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
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
	
	; Version codename
	<? if($version_codename != ''): ?>
	${NSD_CreateLabel} $1 115u 110u 10u '"<?= $version_codename ?>"'
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
	<? endif; ?>
	
	<? endif; ?>
	
	; Website URL
	${NSD_CreateLabel} $1 170u 110u 10u "<?= $project_url ?>"
	Pop $R0
	${NSD_AddStyle} $R0 ${SS_CENTER}
	SetCtlColors $R0 "774400" transparent
	SendMessage $R0 ${WM_SETFONT} $0 1
	
	; Move side image a bit and put it behind everything else
	System::Call 'USER32::SetWindowPos(i $mui.WelcomePage.Image, i1, i $1, i0, i0, i0, i1)'
	System::Call 'USER32::SetWindowPos(i $mui.FinishPage.Image, i1, i $1, i0, i0, i0, i1)'
	
FunctionEnd


;------------------------------------------------------------------------------
;Uninstaller Section

Section "Uninstall"
	
	; This will handle all files to uninstall
	; Registry keys to remove are handled manually below
	Call un.AutoUninstallFromLogFile
	
	; Was missing from uninstall.log for Arx Libertatis 1.1.2
	Delete "$INSTDIR\OpenAL32.dll"
	
	;RMDir "$INSTDIR"
	
	;!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	
	DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis"
	DeleteRegKey SHCTX "Software\ArxLibertatis"
	
SectionEnd

;------------------------------------------------------------------------------
;Uninstaller Functions

Function un.onInit
	
	SetRegView 64
	
	!insertmacro MULTIUSER_UNINIT
	!insertmacro MUI_UNGETLANGUAGE
	
FunctionEnd


;------------------------------------------------------------------------------
Function DetectArx
	; If no source data directory was specified, don't bother with the validation
	${If} $ArxFatalisInstallDir == ""
		goto end_success
	${EndIf}
	
	${DetectArxLanguage} $ArxFatalisInstallDir
	StrCpy $ArxFatalisLanguage $0
	
	${Switch} $ArxFatalisLanguage
		${Case} "demo"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (Demo) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "de"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (German) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "en"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (English) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "es"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (Spanish) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "fr"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (French) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "it"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (Italian) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "ru"
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Arx Fatalis (Russian) found, continue ?" IDNO end_abort
			${Break}
		
		${Case} "not_found"
			StrCpy $ArxFatalisLanguage "en"
			StrCpy $1 "No speech.pak file found in this directory. Do you still want to continue and use this source directory ?"
			MessageBox MB_YESNO|MB_ICONSTOP '$1' IDNO end_abort
			${Break}
		
		${Case} "unknown"
			StrCpy $ArxFatalisLanguage "en"
			StrCpy $1 "Arx Fatalis files were found but the version is unknown to this installer. Make sure you have applied the 1.21 patch on your original Arx Fatalis install before running this installer. Do you want to continue anyway ?"
			MessageBox MB_YESNO|MB_ICONSTOP '$1' IDNO end_abort
			${Break}
		
		${Default}
			MessageBox MB_OK|MB_ICONSTOP 'INTERNAL INSTALLER ERROR. Detected language is \"$ArxFatalisLanguage\" Please select another directory.'
			goto end_abort
	${EndSwitch}
	
	goto end_success
	
end_abort:
	Abort
	
end_success:
	
FunctionEnd
