;; From http://nsis.sourceforge.net/Uninstall_only_installed_files

!ifndef UNINSTALL_LOG_INCLUDED
!define UNINSTALL_LOG_INCLUDED

!include "LogicLib.nsh"
!include "NSISList.nsh"

!include "PathUtil.nsh"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Set the name of the uninstall log
!define UninstallLog "uninstall.log"
Var UninstallLog

!define UninstallLogInit 'Call UninstallLogInit'

Function UninstallLogInit
	
	${List.Create} UninstallLog
	${Map.Create} UninstallLogInfo
	
FunctionEnd

; Add an old item that should be removed if not re-installed
!define UninstallLogAddOld '!insertmacro UninstallLogAddOld'

!macro UninstallLogAddOld Item
	Push "${Item}"
	Call UninstallLogAddOld
!macroend

Function UninstallLogAddOld
	
	Exch $0 ; Item
	Push $1
	
	${If} ${FileExists} "$0"
	${OrIf} ${FileExists} "$0.bak"
		${NormalizePath} "$0" "$0"
		${Map.Get} $1 UninstallLogInfo "$0"
		${If} $1 == __NULL
			${List.Add} UninstallLog "$0"
			${Map.Set} UninstallLogInfo "$0" "old"
		${EndIf}
	${EndIf}
	
	Pop $1
	Pop $0
	
FunctionEnd

; Add an old item that should be removed if not re-installed
!define UninstallLogRead '!insertmacro UninstallLogRead'

!macro UninstallLogRead LogFile
	Push "${LogFile}"
	Call UninstallLogRead
!macroend

Function UninstallLogRead
	
	Exch $0 ; LogFile
	Push $1
	
	${If} ${FileExists} "$0"
		
		${UninstallLogAddOld} "$0"
		
		ClearErrors
		SetFileAttributes "$0" NORMAL
		FileOpen $0 "$0" r
		
		${Do}
			FileRead $0 $1
			${If} ${Errors}
				${Break}
			${EndIf}
			StrCpy $1 $1 -2
			${If} $1 != ""
				${UninstallLogAddOld} "$1"
			${EndIf}
		${Loop}
		
		FileClose $0
		
	${EndIf}
	
	Pop $1
	Pop $0
	
FunctionEnd

; Mark an item as old / orphan / keep
!define UninstallLogMark '!insertmacro UninstallLogMark'

!macro UninstallLogMark Mode Item
	Push "${Mode}"
	Push "${Item}"
	Call UninstallLogMark
!macroend

Function UninstallLogMark
	
	Exch $0 ; Item
	Exch
	Exch $1 ; Mode
	
	${NormalizePath} "$0" "$0"
	${Map.Set} UninstallLogInfo "$0" "$1"
	
	Pop $1
	Pop $0
	
FunctionEnd

; Mark an item as not part of the install so that it will be removed be neither cleanup nor uninstall
!define UninstallLogOrphan '${UninstallLogMark} "orphan"'

; Keep an item that should not be removed by cleanup
!define UninstallLogKeep '${UninstallLogMark} "keep"'

!define UninstallLogOpen '!insertmacro UninstallLogOpen'

!macro UninstallLogOpen LogFile
	Push "${LogFile}"
	Call UninstallLogOpen
!macroend

Function UninstallLogOpen
	
	Exch $0 ; LogFile
	
	SetFileAttributes "$0" NORMAL
	ClearErrors
	FileOpen $UninstallLog "$0" a
	FileSeek $UninstallLog 0 END
	${If} ${Errors}
		MessageBox MB_OK|MB_ICONSTOP "$(UNINSTALL_LOG)"
		Abort
	${EndIf}
	
	Pop $0
	
FunctionEnd

; Add a new item that should be recorded in the uninstall log but not removed by cleanup
!define UninstallLogAdd '!insertmacro UninstallLogAdd'

!macro UninstallLogAdd Item
	Push "${Item}"
	Call UninstallLogAdd
!macroend

Function UninstallLogAdd
	
	Exch $0 ; Item
	Push $1
	
	${NormalizePath} "$0" $0
	${Map.Get} $1 UninstallLogInfo "$0"
	${If} $1 == __NULL
		${List.Add} UninstallLog "$0"
		FileWrite $UninstallLog "$0$\r$\n"
	${EndIf}
	${Map.Set} UninstallLogInfo "$0" "keep"
	
	Pop $1
	Pop $0
	
	ClearErrors
	
FunctionEnd

; Backup a file if it is not owned by the installer
!define UninstallLogBackup '!insertmacro UninstallLogBackup'

!macro UninstallLogBackup Path
	Push "${Path}"
	Call UninstallLogBackup
!macroend

Function UninstallLogBackup
	
	Exch $0 ; Path
	Push $1
	
	${Map.Get} $1 UninstallLogInfo "$0"
	${If} $1 != "old"
	${AndIf} $1 != "keep"
	${AndIf} ${FileExists} "$0"
	${AndIfNot} ${FileExists} "$0.bak"
		${UninstallLogAdd} "$0"
		Rename "$0" "$0.bak"
	${EndIf}
	
	Pop $1
	Pop $0
	
FunctionEnd

!define File "!insertmacro File"

!macro File FilePath FileName
	${UninstallLogAdd} "$OUTDIR\${FileName}"
	File "/oname=${FileName}" "${FilePath}\${FileName}"
!macroend

!define CreateShortcut "!insertmacro CreateShortcut"

!macro CreateShortcut FilePath FilePointer
	${UninstallLogAdd} "${FilePath}"
	CreateShortcut "${FilePath}" "${FilePointer}"
!macroend

!define CopyFiles "!insertmacro CopyFiles"

!macro CopyFiles SourcePath DestPath DestUninstall
	${UninstallLogAdd} "${DestUninstall}"
	CopyFiles /SILENT "${SourcePath}" "${DestPath}"
!macroend

!define Rename "!insertmacro Rename"

!macro Rename SourcePath DestPath
	${UninstallLogAdd} "${DestPath}"
	Rename "${SourcePath}" "${DestPath}"
!macroend

!define CreateDirectory "!insertmacro CreateDirectory"

!macro CreateDirectory Path
	${UninstallLogAdd} "${Path}"
	CreateDirectory "${Path}"
!macroend

!define CreateDirectoryRecursive "!insertmacro CreateDirectoryRecursive"

!macro CreateDirectoryRecursive Parent Directory
	Push "${Parent}"
	Exch $0
	Push "${Directory}"
	Call CreateDirectoryRecursive
	Pop $0
!macroend

Function CreateDirectoryRecursive
	
	Exch $1 ; Directory
	Push $2
	
	${Map.Get} $2 UninstallLogInfo "$1"
	${If} $1 != ""
	${AndIf} $2 != "keep"
		${GetDirectory} "$1" $2
		Push "$2"
		Call CreateDirectoryRecursive
		${CreateDirectory} "$0$1"
	${EndIf}
	
	Pop $2
	Pop $1
	
FunctionEnd

!define SetOutPath "!insertmacro SetOutPath"

!macro SetOutPath Path
	${UninstallLogAdd} "${Path}"
	SetOutPath "${Path}"
!macroend

!define WriteUninstaller "!insertmacro WriteUninstaller"

!macro WriteUninstaller Path
	${UninstallLogAdd} "${Path}"
	WriteUninstaller "${Path}"
!macroend

!macro UninstallLogRemove Item
	${If} ${FileExists} "${Item}\*.*"
		RMDir "${Item}"
	${ElseIf} ${FileExists} "${Item}"
		Delete "${Item}"
	${EndIf}
	${If} ${FileExists} "${Item}.bak"
		Rename "${Item}.bak" "${Item}"
	${EndIf}
!macroend

!define UninstallLogRemoveOld '!insertmacro UninstallLogRemoveOld'

!macro UninstallLogRemoveOld LogFile
	Push "${LogFile}"
	Call UninstallLogRemoveOld
!macroend

Function UninstallLogRemoveOld
	
	Exch $0 ; LogFile
	Push $1
	Push $2
	Push $3
	
	${List.Sort} UninstallLog
	
	; Remove old files in reverse order
	${List.Count} $1 UninstallLog
	${DoWhile} $1 > 0
		IntOp $1 $1 - 1
		${List.Get} $2 UninstallLog $1
		${If} $2 != $0
			${Map.Get} $3 UninstallLogInfo "$2"
			${If} $3 == "old"
				!insertmacro UninstallLogRemove "$2"
			${EndIf}
		${EndIf}
	${Loop}
	
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!define UninstallLogClean '!insertmacro UninstallLogClean'

!macro UninstallLogClean LogFile
	Push "${LogFile}"
	Call UninstallLogClean
!macroend

Function UninstallLogClean
	
	Exch $0 ; LogFile
	Push $1
	Push $2
	Push $3
	Push $4
	Push $5
	
	FileClose $UninstallLog
	
	${UninstallLogRemoveOld} "$0"
	
	; Write new uninstall log with only files that are not old or orphaned
	ClearErrors
	FileOpen $1 "$0" w
	${List.Count} $2 UninstallLog
	StrCpy $3 0
	${DoWhile} $3 < $2
		${List.Get} $4 UninstallLog $3
		${Map.Get} $5 UninstallLogInfo "$4"
		${If} $5 == "keep"
			FileWrite $1 "$4$\r$\n"
		${EndIf}
		IntOp $3 $3 + 1
	${Loop}
	FileClose $1
	${If} ${Errors}
		MessageBox MB_OK|MB_ICONSTOP "$(UNINSTALL_LOG)"
	${EndIf}
	SetFileAttributes "$0" READONLY
	
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd


!define UninstallLogGetSize '!insertmacro UninstallLogGetSize'

!macro UninstallLogGetSize LogFile SizeResult
	Push "${LogFile}"
	Call UninstallLogGetSize
	Pop ${SizeResult}
!macroend

Function UninstallLogGetSize
	
	Exch $0 ; LogFile
	Push $1
	Push $2
	Push $3
	
	${GetFileSize} "$0" $0
	
	; Remove old files in reverse order
	${List.Count} $1 UninstallLog
	${DoWhile} $1 > 0
		IntOp $1 $1 - 1
		${List.Get} $2 UninstallLog $1
		${Map.Get} $3 UninstallLogInfo "$2"
		${If} $3 == "keep"
			${GetFileSize} "$2" $3
			DetailPrint "'$2' $3"
			IntOp $0 $0 + $3
		${EndIf}
	${Loop}
	
	Pop $3
	Pop $2
	Pop $1
	Exch $0 ; SizeResult
	
FunctionEnd

!define UninstallLogRemoveAll '!insertmacro UninstallLogRemoveAll'

!macro UninstallLogRemoveAll LogFile
	Push "${LogFile}"
	Call un.UninstallLogRemoveAll
!macroend

Function un.UninstallLogRemoveAll
	
	Exch $0 ; LogFile
	Push $1
	Push $2
	Push $3
	
	; Read log file and push all entries on the stack
	SetFileAttributes "$0" NORMAL
	ClearErrors
	FileOpen $1 "$0" r
	${If} ${Errors}
		MessageBox MB_OK|MB_ICONSTOP "$(UNINSTALL_LOG)"
	${EndIf}
	StrCpy $2 0
	ClearErrors
	${Do}
		FileRead $1 $3
		${If} ${Errors}
			${Break}
		${EndIf}
		StrCpy $3 "$3" -2
		Push $3
		IntOp $2 $2 + 1
	${Loop}
	FileClose $1
	
	; Remove files in reverse order
	${DoWhile} $2 > 0
		IntOp $2 $2 - 1
		Pop $1
		!insertmacro UninstallLogRemove "$1"
	${Loop}
	
	Delete "$0"
	
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!endif ; UNINSTALL_LOG_INCLUDED
