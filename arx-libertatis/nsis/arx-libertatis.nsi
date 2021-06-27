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

!include "PathUtil.nsh"
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

Var ExistingInstall32
Var ExistingInstallMode
Var ExistingInstallLocation
Var ExistingInstallType
Var ExistingInstallTypeUnclear
Var ExistingArxFatalisLocation
Var ShortcutSectionReached

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

;Remember the installer language
!define MUI_LANGDLL_ALWAYSSHOW
!define MUI_LANGDLL_REGISTRY_ROOT "SHCTX"
!define MUI_LANGDLL_REGISTRY_KEY "Software\ArxLibertatis"
!define MUI_LANGDLL_REGISTRY_VALUENAME "InstallerLanguage"

;------------------------------------------------------------------------------
;Reserve Files

; These should be in the order of their first use
!insertmacro MUI_RESERVEFILE_LANGDLL
ReserveFile /plugin System.dll
ReserveFile /plugin UserInfo.dll
ReserveFile /plugin nsDialogs.dll
ReserveFile /plugin NSISList.dll
!insertmacro WELCOME_FINISH_PAGE_RESERVE
ReserveFile /plugin SysCompImg.dll

;------------------------------------------------------------------------------
;Pages

!insertmacro WELCOME_PAGE
!insertmacro SET_ARX_FATALIS_LOCATION_PAGE
!insertmacro COMPONENTS_PAGE
!insertmacro CHANGE_ARX_FATALIS_LOCATION_PAGE
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

!define MUI_UNFINISHPAGE

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

!undef MUI_UNFINISHPAGE

;------------------------------------------------------------------------------
;Sections

!define UNINSTALL_CMDLINE "$\"$INSTDIR\uninstall.exe$\" /$MultiUser.InstallMode"

!define INSTTYPE_UPDATE_REPAIR 0
!define /math INSTTYPE_UPDATE_REPAIR_MASK 1 << ${INSTTYPE_UPDATE_REPAIR}
!define INSTTYPE_UNINSTALL 1
InstType "/CUSTOMSTRING=$(ARX_MODIFY_INSTALL)"

Section - Main
	SectionIn RO
	
	Push $0
	
	SetDetailsPrint both
	DetailPrint "$(ARX_INSTALL_STATUS)"
	SetDetailsPrint listonly
	
	; Set output path to the installation directory.
	SetOutPath "$INSTDIR"
	
	${UninstallLogOpen} "$INSTDIR\${UninstallLog}"
	
	<?
	$count = 0;
	$size = 0;
	$files = explode("\n", file_get_contents($outdir . "/files"));
	foreach($files as $file) {
		if($file != '' && substr($file, -1) != '/') {
			$count++;
			$size += ceil(filesize( $outdir . "/build/" . $file ) / 1024);
		}
	}
	$count++; // uninstaller
	?>
	!define MAIN_SECTION_COUNT "<?= $count ?>"
	!define MAIN_SECTION_SIZE "<?= $size ?>"
	${ProgressBarBeginSection} ${MAIN_SECTION_SIZE} ${MAIN_SECTION_COUNT}
	
	; First, store whatever we need to clean things up on error
	WriteRegStr SHCTX "Software\ArxLibertatis" "InstallLocation" "$INSTDIR"
	Call StoreInstallTypeInRegistry
	WriteRegStr SHCTX "Software\ArxLibertatis" "DataDir" "$ArxFatalisLocation"
	${GetArxFatalisStore} "$INSTDIR" $0
	WriteRegStr SHCTX "Software\ArxLibertatis" "Store" "$0"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayName" "Arx Libertatis"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayIcon" "$\"$INSTDIR\arx.exe$\""
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "UninstallString" "${UNINSTALL_CMDLINE}"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "QuietUninstallString" "${UNINSTALL_CMDLINE} /S"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "URLInfoAbout" "<?= $project_url ?>"
	WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayVersion" "<?= $version ?>"
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoModify" 1
	WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "NoRepair" 1
	
	; Backup old arx.exe and arx.bat so that we can restore vanilla AF when uninstalling
	${UninstallLogBackup} "$INSTDIR\arx.exe"
	${UninstallLogBackup} "$INSTDIR\arx.bat"
	
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
	
	${Do}
		StrCpy $0 "$INSTDIR\uninstall.exe"
		SetFileAttributes "$0" NORMAL
		${WriteUninstaller} "$0"
		${IfNot} ${Errors}
			${Break}
		${EndIf}
		StrCpy $0 "$(^FileError)"
		${If} ${Cmd} `MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION "$0" /SD IDIGNORE IDABORT abort IDIGNORE`
			SetAutoClose false
			${Break}
			abort:
			Abort
		${EndIf}
	${Loop}
	${ProgressBarUpdate} 0
	
	${ProgressBarEndSection}
	
	Pop $0
	
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
		WriteRegStr SHCTX "Software\ArxLibertatis" "DataDir" "$ArxFatalisLocation"
		
		${ProgressBarEndSection}
		
	${EndIf}
	
SectionEnd

Function ShortcutSectionReached
	${If} $ShortcutSectionReached != 1
		DetailPrint ""
		SetDetailsPrint both
		DetailPrint "$(ARX_CREATE_SHORTCUT_STATUS)"
		SetDetailsPrint listonly
		StrCpy $ShortcutSectionReached 1
	${EndIf}
FunctionEnd

Section - StartMenu
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		Call ShortcutSectionReached
		${CreateDirectory} "$SMPROGRAMS\$StartMenuFolder"
		${CreateShortCut} "$SMPROGRAMS\$StartMenuFolder\Play Arx Libertatis.lnk" "$INSTDIR\arx.exe"
		${CreateShortCut} "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
		AddSize 2
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "$(ARX_CREATE_DESKTOP_ICON)" Desktop
	Call ShortcutSectionReached
	${CreateShortCut} "$DESKTOP\Arx Libertatis.lnk" "$INSTDIR\arx.exe"
	AddSize 1
SectionEnd

Section "$(ARX_CREATE_QUICKLAUNCH_ICON)" QuickLaunch
	Call ShortcutSectionReached
	${CreateShortCut} "$QUICKLAUNCH\Arx Libertatis.lnk" "$INSTDIR\arx.exe"
	AddSize 1
SectionEnd

SectionGroupEnd

Section - Cleanup

	Push $0
	
	${ProgressBarBeginSection} 0 0
	
	${If} ${SectionIsSelected} ${Main}
		DetailPrint ""
	${EndIf}
	SetDetailsPrint both
	DetailPrint "$(ARX_CLEANUP_STATUS)"
	SetDetailsPrint listonly
	
	${If} ${SectionIsSelected} ${Main}
		
		${UninstallLogClean} "$INSTDIR\${UninstallLog}"
		
		${UninstallLogGetNewSize} "$INSTDIR\${UninstallLog}" "" $0
		WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "EstimatedSize" $0
		
	${Else}
		
		${UninstallLogRemoveOld} ""
		
	${EndIf}
	
	${If} $ExistingInstallLocation != ""
	${AndIf} $INSTDIR != $ExistingInstallLocation
	${OrIfNot} ${SectionIsSelected} ${Main}
		
		RMDir "$ExistingInstallLocation"
		
		${If} $ExistingInstallType == "separate"
		${AndIf} ${FileExists} "$ExistingInstallLocation"
		${AndIf} ${Cmd} `MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(UNINSTALL_NOT_EMPTY)$\n$\n$ExistingInstallLocation" /SD IDNO IDYES`
			RMDir /r "$ExistingInstallLocation"
		${EndIf}
		
	${EndIf}
	
	; Clean up old registry keys
	${If} $MultiUser.InstallMode != $ExistingInstallMode
	${OrIfNot} ${SectionIsSelected} ${Main}
	${OrIf} $ExistingInstall32 == 1
		${If} $ExistingInstall32 == 1
			SetRegView 32
		${EndIf}
		${If} $ExistingInstallMode == "AllUsers"
			DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis"
			DeleteRegKey HKLM "Software\ArxLibertatis"
		${ElseIf} $ExistingInstallMode == "CurrentUser"
			DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis"
			DeleteRegKey HKCU "Software\ArxLibertatis"
		${EndIf}
		${If} $ExistingInstall32 == 1
			SetRegView 64
		${EndIf}
	${EndIf}
	
	${ProgressBarEndSection}
	
	Pop $0
	
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
			
			${GetArxFatalisStore} "$ArxFatalisLocation" $3
			${If} $3 == "steam"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_PATCH_STEAM)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "bethesda"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_PATCH_BETHESDA)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "windows"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_PATCH_WINDOWS)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${ElseIf} $3 == "gog"
			${OrIf} $0 != "patchable"
				StrCpy $1 "$1$\n$\n$(ARX_VERIFY_DATA_PATCH_REINSTALL)$\n$(ARX_VERIFY_DATA_REINSTALL)"
			${Else}
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
			
		${EndIf}
		
		DetailPrint ""
		
		${ProgressBarEndSection}
		
		Pop $3
		Pop $2
		Pop $1
		Pop $0
		
	${EndIf}
	
	SetDetailsPrint both
	
SectionEnd

!define SECTION_MAX ${VerifyData}

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
	
	SetRegView 64
	!insertmacro MULTIUSER_INIT
	${If} $MultiUser.DefaultKeyValue == ""
		SetRegView 32
		!insertmacro MULTIUSER_INIT
		${If} $MultiUser.DefaultKeyValue != ""
			StrCpy $ExistingInstall32 1
		${EndIf}
	${EndIf}
	!insertmacro MUI_LANGDLL_DISPLAY
	SetRegView 64
	
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
	
	Call InitArxFatalisData
	
	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	
	!insertmacro WELCOME_FINISH_PAGE_INIT
	!insertmacro ARX_FATALIS_LOCATION_PAGE_INIT
	!insertmacro COMPONENTS_PAGE_INIT
	
	${UninstallLogInit}
	
	${If} $MultiUser.DefaultKeyValue != ""
	${AndIf} ${FileExists} "$MultiUser.DefaultKeyValue\*.*"
		
		Push $0
		Push $1
		
		${If} $ExistingInstall32 == 1
			SetRegView 32
		${EndIf}
		
		StrCpy $ExistingInstallMode "$MultiUser.InstallMode"
		${NormalizePath} "$MultiUser.DefaultKeyValue" $ExistingInstallLocation
		ReadRegStr $ExistingInstallType SHCTX "Software\ArxLibertatis" "InstallType"
		ReadRegStr $ExistingArxFatalisLocation SHCTX "Software\ArxLibertatis" "DataDir"
		${NormalizePath} "$ExistingArxFatalisLocation" $ExistingArxFatalisLocation
		${Map.Get} $0 ArxFatalisLocationInfo "$ExistingInstallLocation"
		${If} $0 == __NULL
			ReadRegStr $0 SHCTX "Software\ArxLibertatis" "Store"
			${If} $0 != ""
				${Map.Set} ArxFatalisLocationInfo "$ExistingInstallLocation" "${MU_UNKNOWN}:$0"
			${EndIf}
		${EndIf}
		
		StrCpy $INSTDIR "$ExistingInstallLocation"
		
		${UninstallLogRead} "$INSTDIR\${UninstallLog}"
		Call AdoptOldFiles
		${UninstallLogOrphan} "$INSTDIR"
		
		; Guess install type since older installers did not support it
		${If} $ExistingInstallType == ""
			StrCpy $ExistingInstallType "separate"
			${If} $ExistingInstallLocation == $ExistingArxFatalisLocation
				${Map.Get} $0 ArxFatalisLocationInfo "$ExistingArxFatalisLocation"
				${If} $0 != __NULL
					; Was installed to a known Arx Fatalis location
					; Assume that the user intended to patch the AF install and that the AF data is not really owned by us
					StrCpy $ExistingInstallType "patch"
					${OrphanArxFatalisData} "$ExistingArxFatalisLocation"
				${Else}
					; User will have to select install type
					; We will orphan the AF data if they coose to patch and keep the AF location
					StrCpy $ExistingInstallTypeUnclear 1
				${EndIf}
			${EndIf}
		${EndIf}
		
		ReadRegStr $0 SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis" "DisplayVersion"
		${If} $0 == "<?= $version ?>"
			InstTypeSetText ${INSTTYPE_UPDATE_REPAIR} "$(ARX_REPAIR_INSTALL)"
			InstTypeSetText -1 "Yo"
		${Else}
			InstTypeSetText ${INSTTYPE_UPDATE_REPAIR} "$(ARX_UPDATE_INSTALL)"
		${EndIf}
		
		InstTypeSetText ${INSTTYPE_UNINSTALL} "$(ARX_UNINSTALL)"
		
		${If} $ExistingInstallType == "patch"
		
			StrCpy $SecPatchInstall ${SF_SELECTED}
			StrCpy $SecSeparateInstall 0
			SectionSetInstTypes ${PatchInstall} ${INSTTYPE_UPDATE_REPAIR_MASK}
			
		${Else}
			
			StrCpy $SecPatchInstall 0
			StrCpy $SecSeparateInstall ${SF_SELECTED}
			SectionSetInstTypes ${SeparateInstall} ${INSTTYPE_UPDATE_REPAIR_MASK}
			
			StrCpy $SecCopyData 0
			${If} $ExistingArxFatalisLocation == $ExistingInstallLocation
				${Map.Get} $0 UninstallLogInfo "$ExistingArxFatalisLocation\data.pak"
				${If} $0 == "old"
					StrCpy $SecCopyData ${SF_SELECTED}
					SectionSetInstTypes ${CopyData} ${INSTTYPE_UPDATE_REPAIR_MASK}
				${Else}
					; Old installers always set DataDir even if no data was copied
					StrCpy $ExistingArxFatalisLocation ""
				${EndIf}
			${EndIf}
			
			SectionSetInstTypes ${StartMenu} ${INSTTYPE_UPDATE_REPAIR_MASK}
			
			StrCpy $SecDesktop 0
			${If} ${FileExists} "$DESKTOP\Arx Libertatis.lnk"
				StrCpy $SecDesktop ${SF_SELECTED}
				SectionSetInstTypes ${Desktop} ${INSTTYPE_UPDATE_REPAIR_MASK}
			${EndIf}
			
			StrCpy $SecQuickLaunch 0
			${If} ${FileExists} "$QUICKLAUNCH\Arx Libertatis.lnk"
				StrCpy $SecQuickLaunch ${SF_SELECTED}
				SectionSetInstTypes ${QuickLaunch} ${INSTTYPE_UPDATE_REPAIR_MASK}
				SectionSetText ${QuickLaunch} "$(ARX_CREATE_QUICKLAUNCH_ICON)" ; Unhide section on Windows 7+
			${EndIf}
			
		${EndIf}
		
		StrCpy $ArxFatalisLocation "$ExistingArxFatalisLocation"
		Call UpdateArxFatalisLocationSize
		
		${UninstallLogGetOldSize} "$ExistingInstallLocation\${UninstallLog}" "" $0
		${GetFileSize} "$ExistingInstallLocation\uninstall.exe" $1
		IntOp $0 $0 - $1
		IntOp $0 0 - $0
		SectionSetSize ${Cleanup} $0
		
		${If} $ExistingInstall32 == 1
			SetRegView 64
		${EndIf}
		
		Pop $1
		Pop $0
		
	${EndIf}
	
FunctionEnd

Function BeforeInstall
	
	${NormalizePath} "$INSTDIR" $INSTDIR
	
	${IfNot} ${SectionIsSelected} ${PatchInstall}
	${AndIfNot} ${SectionIsSelected} ${SeparateInstall}
		!insertmacro UnselectSection ${Main}
		!insertmacro UnselectSection ${VerifyData}
	${EndIf}
	
	; Handle switching install modes
	${If} $ExistingInstallMode != ""
	${AndIf} $ExistingInstallMode != $MultiUser.InstallMode
	${OrIf} $ExistingInstall32 == 1
		Push $0
		${If} $MultiUser.InstallMode == "AllUsers"
			ReadRegStr $0 HKLM "Software\ArxLibertatis" "InstallLocation"
		${ElseIf} $MultiUser.InstallMode == "CurrentUser"
			ReadRegStr $0 HKCU "Software\ArxLibertatis" "InstallLocation"
		${EndIf}
		${NormalizePath} "$0" $0
		${If} $0 != ""
		${AndIf} $0 != $ExistingInstallLocation
		${AndIf} $0 != $INSTDIR
			${UninstallLogRead} "$0\${UninstallLog}"
			${UninstallLogAddOld} "$0"
		${EndIf}
		Pop $0
	${EndIf}
	
	; Handle switching install locations
	${If} $INSTDIR != $ExistingInstallLocation
		${UninstallLogRead} "$INSTDIR\${UninstallLog}"
		Call AdoptOldFiles
		${UninstallLogOrphan} "$INSTDIR"
	${EndIf}
	
	${If} $ExistingInstallTypeUnclear == 1
	${AndIfNot} ${SectionIsSelected} ${SeparateInstall}
	${AndIf} $ArxFatalisLocation == $ExistingArxFatalisLocation
		${OrphanArxFatalisData} "$ExistingArxFatalisLocation"
	${EndIf}
	
FunctionEnd

Function AdoptOldFiles
	
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
	
FunctionEnd

!macro UninstallSuggestRepair Store Result
	${If} "${Store}" == "steam"
		StrCpy ${Result} "$(UNINSTALL_REPAIR)$\n$\n$(ARX_VERIFY_DATA_PATCH_STEAM)"
	${ElseIf} "${Store}" == "bethesda"
		StrCpy ${Result} "$(UNINSTALL_REPAIR)$\n$\n$(ARX_VERIFY_DATA_PATCH_BETHESDA)"
	${ElseIf} "${Store}" == "windows"
		StrCpy ${Result} "$(UNINSTALL_REPAIR)$\n$\n$(ARX_VERIFY_DATA_PATCH_WINDOWS)"
	${ElseIf} "${Store}" == "gog"
		StrCpy ${Result} "$(UNINSTALL_REPAIR)$\n$\n$(ARX_VERIFY_DATA_PATCH_REINSTALL)"
	${Else}
		StrCpy ${Result} "$(UNINSTALL_REPAIR)$\n$\n$(ARX_VERIFY_DATA_PATCH)$\n${ARX_PATCH_URL}"
	${EndIf}
!macroend

!insertmacro WELCOME_FINISH_PAGE_FUNCTIONS
!insertmacro ARX_FATALIS_LOCATION_PAGE_FUNCTIONS
!insertmacro COMPONENTS_PAGE_FUNCTIONS
!insertmacro INSTALLMODE_PAGE_FUNCTIONS
!insertmacro DIRECTORY_PAGE_FUNCTIONS
!insertmacro STARTMENU_PAGE_FUNCTIONS
!insertmacro INSTFILES_PAGE_FUNCTIONS

Function StoreInstallTypeInRegistry
	
	${If} ${SectionIsSelected} ${PatchInstall}
		WriteRegStr SHCTX "Software\ArxLibertatis" "InstallType" "patch"
	${ElseIf} ${SectionIsSelected} ${SeparateInstall}
		WriteRegStr SHCTX "Software\ArxLibertatis" "InstallType" "separate"
	${Else}
		DeleteRegValue SHCTX "Software\ArxLibertatis" "InstallType"
	${EndIf}
	
FunctionEnd

Function .onGUIEnd
	
	${List.Unload}
	
FunctionEnd

;------------------------------------------------------------------------------
;Uninstaller Section

Var un.UninstallWarning

Section "Uninstall"
	
	Push $0
	
	${UninstallLogRemoveAll} "$INSTDIR\${UninstallLog}"
	
	RMDir "$INSTDIR"
	
	ReadRegStr $0 SHCTX "Software\ArxLibertatis" "InstallType"
	${If} ${FileExists} "$INSTDIR"
		${If} $0 == "separate"
		${AndIf} ${Cmd} `MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(UNINSTALL_NOT_EMPTY)$\n$\n$INSTDIR" /SD IDNO IDYES`
			RMDir /r "$INSTDIR"
		${EndIf}
	${EndIf}
	
	${If} $0 == "patch"
		ReadRegStr $0 SHCTX "Software\ArxLibertatis" "Store"
		!insertmacro UninstallSuggestRepair "$0" $un.UninstallWarning
		SetAutoClose true
	${EndIf}
	
	DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\ArxLibertatis"
	DeleteRegKey SHCTX "Software\ArxLibertatis"
	
	Pop $0
	
SectionEnd

;------------------------------------------------------------------------------
;Uninstaller Functions

Function un.onInit
	
	!insertmacro SingleInstanceMutex
	
	SetRegView 64
	
	!insertmacro MULTIUSER_UNINIT
	!insertmacro MUI_UNGETLANGUAGE
	
	StrCpy $INSTDIR "$MultiUser.DefaultKeyValue"
	
FunctionEnd

Function un.onUninstSuccess
	
	${If} $un.UninstallWarning != ""
		MessageBox MB_OK|MB_ICONINFORMATION "$un.UninstallWarning"
	${EndIf}
	
FunctionEnd
