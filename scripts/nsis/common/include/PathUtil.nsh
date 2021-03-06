
!ifndef PATH_UTIL_INCLUDED
!define PATH_UTIL_INCLUDED

!include "LogicLib.nsh"

Function NormalizePath
	
	Exch $0 ; Path
	Push $1
	Push $2
	Push $3
	
	StrCpy $1 ""
	StrLen $2 "$0"
	${DoWhile} $2 > 0
		
		GetFullPathName $3 "$0"
		${If} $3 != ""
			${Break}
		${EndIf}
		
		${Do}
			IntOp $2 $2 - 1
			StrCpy $3 "$0" 1 $2
			${If} $3 == "\"
			${OrIf} $2 == 0
				StrCpy $1 "$0$1" ${NSIS_MAX_STRLEN} $2
				StrCpy $0 "$0" $2
				${Break}
			${ElseIf} $3 == "/"
				IntOp $3 $2 + 1
				StrCpy $1 "$0$1" ${NSIS_MAX_STRLEN} $3
				StrCpy $1 "\$1"
				StrCpy $0 "$0" $2
				${Break}
			${EndIf}
		${Loop}
		
	${Loop}
	
	StrCpy $0 "$3$1"
	
	${If} $0 != ""
		StrCpy $1 $0 1 -1
		${If} $1 == "\"
			StrCpy $0 "$0" -1
		${EndIf}
	${EndIf}
	
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

!macro NormalizePath Path Result
	Push "${Path}"
	Call NormalizePath
	Pop ${Result}
!macroend NormalizePath

; ${NormalizePath} Path Result
; Somewhat normalize the directory Path, storing the result in Result.
; This is a best effort operation - there is no guarantee that all paths referring to the same directory
; will be normalized to a single canonical path.
!define NormalizePath '!insertmacro NormalizePath'

Function IsSubdirectory
	
	Exch $0 ; Parent
	Exch
	Exch $1 ; Subdir
	Push $2
	
	${If} $0 == ""
	
		StrCpy $0 0
		
	${Else}
		
		StrCpy $2 "$0" 1 -1
		${IfNot} $2 == "\"
			StrCpy $0 "$0\"
		${EndIf}
		
		StrLen $2 "$0"
		StrCpy $1 "$1" $2
		
		${If} $0 == $1
			StrCpy $0 1
		${Else}
			StrCpy $0 0
		${EndIf}
		
	${EndIf}
	
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

!macro IsSubdirectory Parent Subdir Result
	Push "${Subdir}"
	Push "${Parent}"
	Call IsSubdirectory
	Pop ${Result}
!macroend

; ${IsSubdirectory} Parent Subdir Result
; Stores 1 in Result if Subdir is a subdirectory of Parent, 0 otherwise
!define IsSubdirectory '!insertmacro IsSubdirectory'

Function GetDirectory
	
	Exch $0 ; Path
	Push $1
	Push $2
	
	StrLen $1 "$0"
	${DoWhile} $1 > 0
		IntOp $1 $1 - 1
		StrCpy $2 "$0" 1 $1
		${If} $2 == "\"
		${OrIf} $2 == "/"
			${Break}
		${EndIf}
	${Loop}
	
	StrCpy $0 "$0" $1
	
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

!macro GetDirectory Path Result
	Push "${Path}"
	Call GetDirectory
	Pop ${Result}
!macroend

; ${GetDirectory} Path Result
; Store the directory component of Path in Result
!define GetDirectory '!insertmacro GetDirectory'

Function GetFileSize
	
	Exch $0 ; Path
	Push $1
	Push $2
	
	FileOpen $1 "$0" r
	${If} $1 == ""
		StrCpy $0 0
	${Else}
		FileSeek $1 0 END $0
		FileClose $1
		IntOp $0 $0 + 1023
		IntOp $0 $0 / 1024
	${EndIf}
	
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

!macro GetFileSize Path Result
	Push "${Path}"
	Call GetFileSize
	Pop ${Result}
!macroend

; ${GetFileSize} Path Result
; Stores the file size in KB of Path in Result
; Returns 0 if the file size could not be determined
!define GetFileSize '!insertmacro GetFileSize'

!endif
