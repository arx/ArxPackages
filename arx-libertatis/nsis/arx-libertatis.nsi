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

!define INSTALLERMUTEXNAME "ArxLibertatisSetup"

!define ARX_BUG_URL "https://arx.vg/bug"
!define ARX_DATA_URL "https://arx.vg/data"
!define ARX_PATCH_URL "https://arx.vg/ArxFatalis_1.21_MULTILANG.exe"

!addincludedir include

!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "MultiUser.nsh"
!include "Sections.nsh"
!include "Winver.nsh"
!include "nsDialogs.nsh"
!include "x64.nsh"

!include "SingleInstanceMutex.nsh"
!include "UninstallLog.nsh"

!include "ArxFatalisData.nsh"
!include "ArxFatalisLocationPage.nsh"
!include "WelcomeFinishPage.nsh"

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
!define MUI_COMPONENTSPAGE_NODESC 

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

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "SHCTX" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ArxLibertatis" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Arx Libertatis"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES

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

Section - Main
	SectionIn RO
	
	SetDetailsPrint listonly
	
	InitPluginsDir
	
	SetDetailsPrint both
	DetailPrint "$(ARX_INSTALL_STATUS)"
	SetDetailsPrint listonly
	
	; Set output path to the installation directory.
	SetOutPath "$INSTDIR"
	
	; First, store whatever we need to clean things up on error
	${WriteUninstaller} "$INSTDIR\uninstall.exe"
	WriteRegStr SHCTX "Software\ArxLibertatis" "InstallLocation" "$INSTDIR"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayName" "Arx Libertatis"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayIcon" "$\"$INSTDIR\arx.exe$\""
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "URLInfoAbout" "<?= $project_url ?>"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayVersion" "<?= $version ?>"
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoModify" 1
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoRepair" 1
	
	; Extract Arx Libertatis binaries
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
	
SectionEnd

;------------------------------------------------------------------------------

Section /o "$(ARX_COPY_DATA)" CopyData
	
	${If} $ArxFatalisLocation != $INSTDIR
		
		DetailPrint ""
		SetDetailsPrint both
		DetailPrint "$(ARX_COPY_DATA_STATUS)"
		SetDetailsPrint listonly
		
		${CopyArxFatalisData} "$ArxFatalisLocation" "$INSTDIR"
		StrCpy $ArxFatalisLocation "$INSTDIR"
		
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

Section - VerifyData
	SectionIn RO
	
	${If} $ArxFatalisLocation != ""
		
		Push $0
		Push $1
		Push $2
		Push $3
		
		DetailPrint ""
		SetDetailsPrint both
		DetailPrint "$(ARX_VERIFY_DATA_STATUS)"
		SetDetailsPrint listonly
		
		${VerifyArxFatalisData} "$ArxFatalisLocation" $0
		
		${If} $0 == ""
			
			DetailPrint "$(Data successfully verified.)"
			
		${Else}
			
			${If} $0 == "nodata"
				StrCpy $1 "$(ARX_FATALIS_LOCATION_EMPTY)"
			${ElseIf} $0 == "mixed"
				StrCpy $1 "$(ARX_VERIFY_DATA_MIXED)"
			${Else}
				StrCpy $1 "$(ARX_VERIFY_DATA_FAILED)"
			${EndIf}
			DetailPrint ""
			DetailPrint "$1"
			
			${GetArxFatalisLocationInfo} "$ArxFatalisLocation" $2 $3
			${If} $3 == "steam"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DAYA_PATCH_STEAM)$\n$(ARX_VERIFY_DATA_REINSTALL)"
				DetailPrint "$(ARX_VERIFY_DAYA_PATCH_STEAM)"
				DetailPrint "$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "bethesda"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DAYA_PATCH_BETHESDA)$\n$(ARX_VERIFY_DATA_REINSTALL)"
				DetailPrint "$(ARX_VERIFY_DAYA_PATCH_BETHESDA)"
				DetailPrint "$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "windows"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DAYA_PATCH_WINDOWS)$\n$(ARX_VERIFY_DATA_REINSTALL)"
				DetailPrint "$(ARX_VERIFY_DAYA_PATCH_WINDOWS)"
				DetailPrint "$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $0 == "patchable"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_PATCH)$\n$(ARX_VERIFY_DATA_REINSTALL)"
				DetailPrint "$(ARX_VERIFY_DATA_PATCH)"
				DetailPrint "$(ARX_VERIFY_DATA_REINSTALL)"
			${EndIf}
			
			DetailPrint "$(ARX_VERIFY_DATA_REPORT)"
			DetailPrint "${ARX_BUG_URL}"
			DetailPrint "$(ARX_COPY_DETAILS)"
			DetailPrint ""
			
			MessageBox MB_OK|MB_ICONEXCLAMATION "$1$\n$\n$(ARX_VERIFY_DATA_REPORT)$\n${ARX_BUG_URL}"
			SetAutoClose false
			SetDetailsView show
			
			StrCpy $ArxFatalisLocation ""
			
		${EndIf}
		
		Pop $3
		Pop $2
		Pop $1
		Pop $0
		
	${EndIf}
	
	WriteRegStr SHCTX "Software\ArxLibertatis" "DataDir" "$ArxFatalisLocation"
	
	SetDetailsPrint both
	
SectionEnd

;------------------------------------------------------------------------------
;Installer Functions

Function .onInit
	
	!insertmacro SingleInstanceMutex
	
	!insertmacro MUI_LANGDLL_DISPLAY
	
	; Check for >= Windows XP SP2
	${IfNot} ${AtLeastWinVista}
		${IfNot} ${IsWinXP}
		${OrIfNot} ${AtLeastServicePack} 2
			MessageBox MB_OK|MB_ICONEXCLAMATION "Arx Libertatis requires Windows XP Service Pack 2 or later."
		${EndIf}
	${EndIf}
	
	SetRegView 64
	
	Call InitArxFatalisData
	
	!insertmacro MULTIUSER_INIT
	
	!insertmacro WELCOME_FINISH_PAGE_INIT
	!insertmacro ARX_FATALIS_LOCATION_PAGE_INIT
	
FunctionEnd

!insertmacro WELCOME_FINISH_PAGE_FUNCTIONS
!insertmacro ARX_FATALIS_LOCATION_PAGE_FUNCTIONS

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
	
	!insertmacro SingleInstanceMutex
	
	SetRegView 64
	
	!insertmacro MULTIUSER_UNINIT
	!insertmacro MUI_UNGETLANGUAGE
	
FunctionEnd
