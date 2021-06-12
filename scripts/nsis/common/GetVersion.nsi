OutFile "GetVersion.exe"
SilentInstall silent
RequestExecutionLevel user ; don't write $EXEDIR\Version.txt with admin permissions and prevent invoking UAC
Var File

!include "LogicLib.nsh"
!include "FileFunc.nsh"

Function ExtractFileVersion
	System::Store S
	pop $4
	push "" ;failed ret
	System::Call 'version::GetFileVersionInfoSize(t"$File",i.r2)i.r0'
	${If} $0 <> 0
		System::Alloc $0
		System::Call 'version::GetFileVersionInfo(t"$File",ir2,ir0,isr1)i.r0 ? e'
		pop $2
		${If} $0 <> 0
		${AndIf} $2 = 0 ;a user comment on MSDN said you should check GLE to avoid crash
			System::Call 'version::VerQueryValue(i r1,t "\VarFileInfo\Translation",*i0r2,*i0)i.r0'
			${If} $0 <> 0
				System::Call '*$2(&i2.r2,&i2.r3)'
				IntFmt $2 %04x $2
				IntFmt $3 %04x $3
				System::Call 'version::VerQueryValue(i r1,t "\StringFileInfo\$2$3\$4",*i0r2,*i0r3)i.r0'
				${If} $0 <> 0
					pop $0
					System::Call *$2(&t$3.s)
				${EndIf}
			${EndIf}
		${EndIf}
		System::Free $1
	${EndIf}
	System::Store L
FunctionEnd

!macro ExtractFileVersion Key
	Push "${key}"
	Call ExtractFileVersion
	Pop $0
	FileWrite $R0 '!define ${Key} "$0"$\n'
!macroend

Section
	
	${GetParameters} $File
	
	## Get file version
	GetDllVersion "$File" $R0 $R1
	IntOp $R2 $R0 / 0x00010000
	IntOp $R3 $R0 & 0x0000FFFF
	IntOp $R4 $R1 / 0x00010000
	IntOp $R5 $R1 & 0x0000FFFF
	StrCpy $R1 "$R2.$R3.$R4.$R5"
 
	## Write it to a !define for use in main script
	FileOpen $R0 "$EXEDIR\Version.nsh" w
	FileWrite $R0 '!define Version "$R1"$\n'
	!insertmacro ExtractFileVersion "CompanyName"
	!insertmacro ExtractFileVersion "FileDescription"
	!insertmacro ExtractFileVersion "FileVersion"
	!insertmacro ExtractFileVersion "InternalName"
	!insertmacro ExtractFileVersion "LegalCopyright"
	!insertmacro ExtractFileVersion "OriginalFilename"
	!insertmacro ExtractFileVersion "ProductName"
	!insertmacro ExtractFileVersion "ProductVersion"
	FileClose $R0
 
SectionEnd
