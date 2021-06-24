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
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "Software\ArxLibertatis"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "InstallLocation"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "Software\ArxLibertatis"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "InstallLocation"
!define MULTIUSER_INSTALLMODE_INSTDIR "Arx Libertatis"
!define MULTIUSER_USE_PROGRAMFILES64

!define INSTALLERMUTEXNAME "ArxLibertatisSetup"

!define ARX_BUG_URL "https://arx.vg/bug"
!define ARX_DATA_URL "https://arx.vg/data"
!define ARX_PATCH_URL "https://arx.vg/ArxFatalis_1.21_MULTILANG.exe"
!define VCREDIST32_URL "https://aka.ms/vs/16/release/vc_redist.x86.exe"
!define VCREDIST64_URL "https://aka.ms/vs/16/release/vc_redist.x64.exe"

!addincludedir include

!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "MultiUser.nsh"
!include "NSISList.nsh"
!include "Sections.nsh"
!include "WinVer.nsh"
!include "nsDialogs.nsh"
!include "x64.nsh"

!include "ProgressBar.nsh"
!include "SingleInstanceMutex.nsh"
!include "UninstallLog.nsh"

!include "ArxFatalisData.nsh"

!include "WelcomeFinishPage.nsh"
!include "ArxFatalisLocationPage.nsh"
!include "ComponentsPage.nsh"
!include "InstallModePage.nsh"
!include "DirectoryPage.nsh"
!include "StartMenuPage.nsh"
!include "InstFilesPage.nsh"

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
!define MUI_ABORTWARNING

;------------------------------------------------------------------------------
;Language Selection Dialog Settings

;!define MUI_LANGDLL_ALLLANGUAGES

;Remember the installer language
!define MUI_LANGDLL_REGISTRY_ROOT "SHCTX" 
!define MUI_LANGDLL_REGISTRY_KEY "Software\ArxLibertatis" 
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;------------------------------------------------------------------------------
;Reserve Files

!insertmacro MUI_RESERVEFILE_LANGDLL
!insertmacro WELCOME_FINISH_PAGE_RESERVE

;------------------------------------------------------------------------------
;Pages

!insertmacro WELCOME_PAGE
!insertmacro ARX_FATALIS_LOCATION_PAGE
!insertmacro COMPONENTS_PAGE
!insertmacro INSTALLMODE_PAGE
!insertmacro DIRECTORY_PAGE
!insertmacro STARTMENU_PAGE
!insertmacro INSTFILES_PAGE
!insertmacro FINISH_PAGE

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

;------------------------------------------------------------------------------
;Sections

!define UNINSTALL_CMDLINE "$\"$INSTDIR\uninstall.exe$\" /$MultiUser.InstallMode"

Section - Main
	SectionIn RO
	
	SetDetailsPrint both
	DetailPrint "$(ARX_INSTALL_STATUS)"
	SetDetailsPrint listonly
	
	; Set output path to the installation directory.
	SetOutPath "$INSTDIR"
	
	${UninstallLogRead} "$INSTDIR\${UninstallLog}"
	
	; Mark old files that used to be part of Arx Libertatis for removal
<?
	$removed = explode("\n", file_get_contents($outdir . "/files.removed"));
	foreach($removed as $file):
		if($file != ''):
	?>
	${UninstallLogAddOld} "$INSTDIR\<?= str_replace('/', '\\', rtrim($file, '/')) ?>"
<?
		endif;
	endforeach;
	?>
	
	${UninstallLogOpen} "$INSTDIR\${UninstallLog}"
	
	<?
	$count = 0;
	$files = explode("\n", file_get_contents($outdir . "/files"));
	foreach($files as $file) {
		if($file != '' && substr($file, -1) != '/') {
			$count++;
		}
	}
	?>
	!define MAIN_SECTION_COUNT "<?= $count ?>"
	Push $0
	SectionGetSize ${Main} $0
	${ProgressBarBeginSection} "$0" ${MAIN_SECTION_COUNT}
	Pop $0
	
	; First, store whatever we need to clean things up on error
	${WriteUninstaller} "$INSTDIR\uninstall.exe"
	WriteRegStr SHCTX "Software\ArxLibertatis" "InstallLocation" "$INSTDIR"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayName" "Arx Libertatis"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayIcon" "$\"$INSTDIR\arx.exe$\""
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "UninstallString" "${UNINSTALL_CMDLINE}"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "QuietUninstallString" "${UNINSTALL_CMDLINE} /S"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "URLInfoAbout" "<?= $project_url ?>"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayVersion" "<?= $version ?>"
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoModify" 1
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoRepair" 1
	${ProgressBarFile} "$INSTDIR\uninstall.exe"
	
	; Extract Arx Libertatis binaries
<?
	foreach($files as $file):
		if($file == '') {
			continue;
		}
		$filename = str_replace('/', '\\', rtrim($file, '/'));
		if(substr($file, -1) == '/'):
	?>
	${CreateDirectory} "$OUTDIR\<?= $filename ?>"
<? else: ?>
	${File} "build" "<?= $filename ?>"
	${ProgressBarUpdate} "<?= ceil(filesize( $outdir . "/build/" . $file ) / 1024) ?>"
<?
		endif;
	endforeach;
	?>
	
	${ProgressBarEndSection}
	
SectionEnd

;------------------------------------------------------------------------------

SectionGroup "$(ARX_PATCH_INSTALL)" PatchInstall

SectionGroupEnd

SectionGroup "$(ARX_SEPARATE_INSTALL)" SeparateInstall

Section /o "$(ARX_COPY_DATA)" CopyData
	
	${If} $ArxFatalisLocation == $INSTDIR
		
		${ProgressBarBeginSection} 0 0
		
		DetailPrint ""
		SetDetailsPrint both
		DetailPrint "$(ARX_KEEP_DATA_STATUS)"
		SetDetailsPrint listonly
		
		${KeepArxFatalisData} "$INSTDIR"
		
		${ProgressBarEndSection}
		
	${Else}
		
		Push $0
		SectionGetSize ${CopyData} $0
		${ProgressBarBeginSection} "$0" $ArxFatalisFileCount
		Pop $0
		
		DetailPrint ""
		SetDetailsPrint both
		DetailPrint "$(ARX_COPY_DATA_STATUS)"
		SetDetailsPrint listonly
		
		${CopyArxFatalisData} "$ArxFatalisLocation" "$INSTDIR"
		StrCpy $ArxFatalisLocation "$INSTDIR"
		
		${ProgressBarEndSection}
		
	${EndIf}
	
SectionEnd

Section - StartMenu
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		${CreateDirectory} "$SMPROGRAMS\$StartMenuFolder"
		${CreateShortCut} "$SMPROGRAMS\$StartMenuFolder\Play Arx Libertatis.lnk" "$INSTDIR\arx.exe"
		${CreateShortCut} "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "$(ARX_CREATE_DESKTOP_ICON)" Desktop
	${CreateShortCut} "$DESKTOP\Arx Libertatis.lnk" "$INSTDIR\arx.exe"
SectionEnd

Section "$(ARX_CREATE_QUICKLAUNCH_ICON)" QuickLaunch
	${CreateShortCut} "$QUICKLAUNCH\Arx Libertatis.lnk" "$INSTDIR\arx.exe"
SectionEnd

SectionGroupEnd

Section - Cleanup
	
	${ProgressBarBeginSection} 0 0
	
	DetailPrint ""
	SetDetailsPrint both
	DetailPrint "$(ARX_CLEANUP_STATUS)"
	SetDetailsPrint listonly
	
	${UninstallLogClean} "$INSTDIR\${UninstallLog}"
	
	${ProgressBarEndSection}
	
SectionEnd

Section - VerifyData
	SectionIn RO
	
	${If} $ArxFatalisLocation != ""
		
		Push $0
		Push $1
		Push $2
		Push $3
		
		SectionGetSize ${CopyData} $0
		${ProgressBarBeginSection} "$0" $ArxFatalisFileCount
		
		DetailPrint ""
		SetDetailsPrint both
		DetailPrint "$(ARX_VERIFY_DATA_STATUS)"
		SetDetailsPrint listonly
		
		${VerifyArxFatalisData} "$ArxFatalisLocation" $0
		
		${If} $0 == ""
			
			DetailPrint "$(ARX_VERIFY_DATA_SUCCESS)"
			
		${Else}
			
			${If} $0 == "nodata"
				StrCpy $1 "$(ARX_FATALIS_LOCATION_EMPTY)"
			${ElseIf} $0 == "mixed"
				StrCpy $1 "$(ARX_VERIFY_DATA_MIXED)"
			${Else}
				StrCpy $1 "$(ARX_VERIFY_DATA_FAILED)"
			${EndIf}
			
			${GetArxFatalisLocationInfo} "$ArxFatalisLocation" $2 $3
			${If} $3 == "steam"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DAYA_PATCH_STEAM)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "bethesda"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DAYA_PATCH_BETHESDA)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "windows"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DAYA_PATCH_WINDOWS)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $0 == "patchable"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_PATCH)$\n${ARX_PATCH_URL}$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${EndIf}
			
			StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_REPORT)$\n${ARX_BUG_URL}"
			
			; DetailPrint does not support newlines so we need to split the message
			DetailPrint ""
			StrCpy $0 0 ; Current slice begin
			StrCpy $2 0 ; Current slice end
			${Do}
				StrCpy $3 "$1" 1 $2
				${If} $3 == "$\n"
					IntOp $2 $2 - $0
					StrCpy $3 "$1" $2 $0
					DetailPrint "$3"
					IntOp $2 $2 + $0
					IntOp $0 $2 + 1
				${ElseIf} $3 == ""
					IntOp $2 $2 - $0
					StrCpy $3 "$1" $2 $0
					DetailPrint "$3"
					${Break}
				${EndIf}
				IntOp $2 $2 + 1
			${Loop}
			DetailPrint "$(ARX_COPY_DETAILS)"
			
			MessageBox MB_OK|MB_ICONEXCLAMATION "$1"
			SetAutoClose false
			SetDetailsView show
			
			StrCpy $ArxFatalisLocation ""
			
		${EndIf}
		
		DetailPrint ""
		
		${ProgressBarEndSection}
		
		Pop $3
		Pop $2
		Pop $1
		Pop $0
		
	${EndIf}
	
	WriteRegStr SHCTX "Software\ArxLibertatis" "DataDir" "$ArxFatalisLocation"
	
	SetDetailsPrint both
	
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${PatchInstall} "$(ARX_PATCH_INSTALL_DESC)"
!insertmacro MUI_DESCRIPTION_TEXT ${SeparateInstall} "$(ARX_SEPARATE_INSTALL_DESC)"
!insertmacro MUI_DESCRIPTION_TEXT ${CopyData} "$(ARX_COPY_DATA_DESC)"
!insertmacro MUI_DESCRIPTION_TEXT ${Desktop} "$(ARX_CREATE_DESKTOP_ICON_DESC)"
!insertmacro MUI_DESCRIPTION_TEXT ${QuickLaunch} "$(ARX_CREATE_QUICKLAUNCH_ICON_DESC)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;------------------------------------------------------------------------------
;Installer Functions

Function .onInit
	
	!insertmacro SingleInstanceMutex
	
	!insertmacro MUI_LANGDLL_DISPLAY
	
	; Check for >= Windows XP SP2
	${IfNot} ${AtLeastWinVista}
		${IfNot} ${IsWinXP}
		${OrIfNot} ${AtLeastServicePack} 2
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(ARX_WINDOWS_XP_SP2)"
		${EndIf}
	${EndIf}
	
	; Check if the UCRT is available
	${IfNot} ${AtLeastWin10}
		Push $0
		System::Call 'KERNEL32::LoadLibrary(t"api-ms-win-crt-runtime-l1-1-0.dll")p.r0'
		${If} $0 == 0
			${If} ${AtLeastWinVista}
				MessageBox MB_OK|MB_ICONEXCLAMATION "$(ARX_WINDOWS_UCRT)$\n$\n$(ARX_WINDOWS_UCRT_VISTA)"
			${ElseIf} ${RunningX64}
				MessageBox MB_OK|MB_ICONEXCLAMATION "$(ARX_WINDOWS_UCRT)$\n$\n$(ARX_WINDOWS_UCRT_XP)$\n${VCREDIST64_URL}"
			${Else}
				MessageBox MB_OK|MB_ICONEXCLAMATION "$(ARX_WINDOWS_UCRT)$\n$\n$(ARX_WINDOWS_UCRT_XP)$\n${VCREDIST32_URL}"
			${EndIf}
		${Else}
			System::Call 'KERNEL32::FreeLibrary(pr0)i.n'
		${EndIf}
		Pop $0
	${EndIf}
	
	SetRegView 64
	
	Call InitArxFatalisData
	
	!insertmacro MULTIUSER_INIT
	
	!insertmacro WELCOME_FINISH_PAGE_INIT
	!insertmacro ARX_FATALIS_LOCATION_PAGE_INIT
	!insertmacro COMPONENTS_PAGE_INIT
	
	${UninstallLogInit}
	
FunctionEnd

!insertmacro WELCOME_FINISH_PAGE_FUNCTIONS
!insertmacro ARX_FATALIS_LOCATION_PAGE_FUNCTIONS
!insertmacro COMPONENTS_PAGE_FUNCTIONS
!insertmacro INSTALLMODE_PAGE_FUNCTIONS
!insertmacro DIRECTORY_PAGE_FUNCTIONS
!insertmacro STARTMENU_PAGE_FUNCTIONS
!insertmacro INSTFILES_PAGE_FUNCTIONS

Function .onGUIEnd
	
	${List.Unload}
	
FunctionEnd

;------------------------------------------------------------------------------
;Uninstaller Section

Section "Uninstall"
	
	${UninstallLogRemoveAll} "$INSTDIR\${UninstallLog}"
	
	RMDir "$INSTDIR"
	
	;!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	
	DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis"
	DeleteRegKey SHCTX "Software\ArxLibertatis"
	
SectionEnd

;------------------------------------------------------------------------------
;Uninstaller Functions

Function un.onInit
	
	!insertmacro SingleInstanceMutex
	
	SetRegView 64
	
	!insertmacro MULTIUSER_UNINIT
	!insertmacro MUI_UNGETLANGUAGE
	
FunctionEnd
