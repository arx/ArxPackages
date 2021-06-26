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

!ifndef ArxFatalisData
!define ArxFatalisData

!include "LogicLib.nsh"
!include "NSISList.nsh"
!include "WinCore.nsh"

!include "PathUtil.nsh"
!include "ProgressBar.nsh"
!include "UninstallLog.nsh"

!define MU_UNKNOWN 0
!define MU_SYSTEM  1
!define MU_USER    2

!define ARX_GOG_GAMEID "1207658680"
!define ARX_STEAM_APPID "1700"
!define ARX_BETHESDA_LAUNCHID "41"
!define ARX_WINDOWS_PACKAGE "BethesdaSoftworks.ArxFatalis_3275kfvn8vcwc"
!define ARX_WINDOWS_APPID "${ARX_WINDOWS_PACKAGE}!Game"

Var UserProgramFiles

Function AddArxFatalisFile
	
	Exch $0 ; Path
	Exch 3
	Exch $1 ; FileInfo
	Exch 2 ;
	Exch $2 ; ChecksumInfo
	Exch
	Exch $3 ; Checksum
	
	${Map.Set} ArxFatalisChecksums "$0:$3" "$2"
	
	${Map.Get} $2 ArxFatalisFileInfo "$0"
	${If} $2 == __NULL
		${List.Add} ArxFatalisFiles "$0"
		${Map.Set} ArxFatalisFileInfo "$0" "$1"
	${EndIf}
	
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro AddArxFatalisFile Path Checksum ChecksumInfo FileInfo
	Push "${FileInfo}"
	Push "${ChecksumInfo}"
	Push "${Checksum}"
	Push "${Path}"
	Call AddArxFatalisFile
!macroend

Function InitArxFatalisData
	
	${List.Create} ArxFatalisFiles
	${Map.Create} ArxFatalisFileInfo
	${Map.Create} ArxFatalisChecksums
	
	!define Add '!insertmacro AddArxFatalisFile'
	
	${Add} "loc.pak" "f397db4080ff9548ac2e19a06b4e6cff" "unpatched" "patch" ; English 1.14 to 1.15
	${Add} "loc.pak" "a47b192493afb5794e2161a62d35b69f" "patched"   "patch" ; English 1.16+
	${Add} "loc.pak" "635500acc5f1f21370d717fa8e7c427e" "unpatched" "patch" ; French 1.13
	${Add} "loc.pak" "3076da43aeb5005f16e24a4992d7cd04" "unpatched" "patch" ; French 1.13.1
	${Add} "loc.pak" "b3f09a49b636ab9ddec29e15b3457fc1" "unpatched" "patch" ; French 1.14 to 1.15
	${Add} "loc.pak" "f8fc448fea12469ed94f417c313fe5ea" "patched"   "patch" ; French 1.16+
	${Add} "loc.pak" "9c0e8a06a9d7f2dd16d2d0a65111e336" "unpatched" "patch" ; German 1.13.1
	${Add} "loc.pak" "24b445075fb40bc58b8b77721b9dc002" "unpatched" "patch" ; German 1.14 to 1.15
	${Add} "loc.pak" "31bc35bca48e430e108db1b8bcc2621d" "patched"   "patch" ; German 1.16+
	${Add} "loc.pak" "668893cfe36b1807be9e15ae02166816" "unpatched" "patch" ; Italian 1.15
	${Add} "loc.pak" "a9e162f2916f5737a95bd8c5bd8a979e" "patched"   "patch" ; Italian 1.16+
	${Add} "loc.pak" "9dcb0f5d7a517be4f1d9190419900892" "patched"   "patch" ; Japanese 1.02j
	${Add} "loc.pak" "a131bf2398ee70a9c22a2bbffd9d0d99" "patched"   "patch" ; Russian 1.18+ (1.16 to 1.17 unknown)
	${Add} "loc.pak" "121f99608814a2c9c5857cfadb665553" "patched"   "patch" ; Spanish 1.21+ (1.16 to 1.20 unknown)
	${Add} "loc.pak" "2ae16d3925c597dca70f960f175def3a" "demo"      "patch" ; English (Demo)
	${Add} "loc.pak" "48c72764e4e032177b106e67bfb30b3c" "demo"      "patch" ; English (Fishtank Demo)
	${Add} "loc.pak" "4a8ac68341d4758a32d9cd04955b115e" "demo"      "patch" ; French (Demo)
	${Add} "loc.pak" "87accec0658aa109a3efa8b41aab61df" "demo"      "patch" ; German (Demo)
	${Add} "loc.pak" "9d84cede805b13fdf7fce856ecc15b19" "demo"      "patch" ; Japanese (Demo)
	
	${Add} "data2.pak" "e9b543432fd47ba53d878f3dd16a6c6c" "unpatched" "patch" ; 1.11 (German)
	${Add} "data2.pak" "79487205cc391cbb47f3da158ce3d0ba" "unpatched" "patch" ; 1.13 (French)
	${Add} "data2.pak" "712251f44f9bab51f3e3013085edc010" "unpatched" "patch" ; 1.13.1 (French)
	${Add} "data2.pak" "5a2b24e06c59115dac15359650e926c3" "unpatched" "patch" ; 1.13.1 (German)
	${Add} "data2.pak" "3d1f6de15f08b7e8f622bf55b4764f6d" "unpatched" "patch" ; 1.14 (English/French)
	${Add} "data2.pak" "2f2f9f8c436bca9c0f9d7a2b1789510d" "unpatched" "patch" ; 1.14 (German)
	${Add} "data2.pak" "1c23a27c5cfdcb4f254e54006231b7be" "unpatched" "patch" ; 1.15 (English/French/Italian)
	${Add} "data2.pak" "242ecd816b2ec9b95c30e583fa493216" "unpatched" "patch" ; 1.15 (German)
	${Add} "data2.pak" "f7e0ce700bf963429ac535ca86f8a7b4" "patched"   "patch" ; 1.16+
	${Add} "data2.pak" "958b78f8f370b06d769843137138c461" "demo"      "patch" ; Demo (English/Japanese)
	${Add} "data2.pak" "8dc1d1b3e85d4a41ae320aa3fa9c649a" "demo"      "patch" ; Demo (French)
	${Add} "data2.pak" "143ba491a357263a2dfad9936a66eeb6" "demo"      "patch" ; Demo (German)
	${Add} "data2.pak" "9ab1215883ed49f5d4c1ffb4aa074f96" "demo"      "patch" ; Fishtank Demo
	
	${Add} "sfx.pak" "2efc9a74c517fd1ee9919900cf4091d2" ""     "" ; Retail
	${Add} "sfx.pak" "ea1b3e6d6f4906905d4a34f07e9a59ac" "demo" "" ; Demo
	${Add} "sfx.pak" "7c907e618969f1712db181e203ace5c4" "demo" "" ; Fishtank Demo
	
	${Add} "data.pak" "a91a0b39a046233debbb10b4850e13eb" ""     "" ; Default - English CD, Stores
	${Add} "data.pak" "7ae3632eef92700cd6c5e143aa0fe67b" ""     "" ; French CD
	${Add} "data.pak" "a88d239dc7919ab113ff45483cb4ad46" ""     "" ; German/Italian CD (censored)
	${Add} "data.pak" "b297ab9ae41a593b13cbdd0ecaf1f999" ""     "" ; Russian CD
	${Add} "data.pak" "5d7ba6e6c79ebf7fbb232eaced9e8ad9" "demo" "" ; Demo (English/French/German)
	${Add} "data.pak" "903dfe1878a0cedff3b941fd3aa22ba9" "demo" "" ; Demo (Japanese)
	${Add} "data.pak" "f819e46acd04feda9f4badaf2339dd53" "demo" "" ; Fishtank Demo
	
	${Add} "speech.pak" "4e8f962d8204bcfd79ce6f3226d6d6de" ""     "" ; English
	${Add} "speech.pak" "4edf9f8c799190590b4cd52cfa5f91b1" ""     "" ; French
	${Add} "speech.pak" "4c3fdb1f702700255924afde49081b6e" ""     "" ; German
	${Add} "speech.pak" "ab8a93161688d793a7c78fbefd7d133e" ""     "" ; German (Bundled)
	${Add} "speech.pak" "81f05dea47c52d43f01c9b44dd8fe962" ""     "" ; Italian
	${Add} "speech.pak" "235b86700fc80b3eb86731d748013a38" ""     "" ; Japanese
	${Add} "speech.pak" "677163bc319cd1e9aa1b53b5fb3e9402" ""     "" ; Russian
	${Add} "speech.pak" "5df8ba0d4ec58bd43d04307eb4c06d86" ""     "" ; Russian CD
	${Add} "speech.pak" "2f88c67ae1537919e69386d27583125b" ""     "" ; Spanish
	${Add} "speech.pak" "62ca7b1751c0615ee131a94f0856b389" "demo" "" ; English (Demo)
	${Add} "speech.pak" "f624502bd04634dad52686de27e2c55f" "demo" "" ; English (Fishtank Demo)
	${Add} "speech.pak" "09038e43508232c44537c162f9e3ecde" "demo" "" ; French (Demo)
	${Add} "speech.pak" "a424fcfc46dd4f11b04030efac15a668" "demo" "" ; German (Demo)
	${Add} "speech.pak" "eeacbd9a845ecc00054934e82e9d7dd3" "demo" "" ; Japanese (Demo)
	
	${Add} "misc\arx.ttf"           "9a95ff96795c034524ba1c2e94ea12c7" "all" "patchonly" ; Default
	${Add} "misc\arx.ttf"           "921561e83786efcd25f92147b60a13db" "all" "patchonly" ; Russian
	${Add} "misc\arx.ttf"           "58eab00842d8adea8d553ae1f66b0c9b" "all" "patchonly" ; Japanese
	${Add} "misc\arx_default.ttf"   "9a95ff96795c034524ba1c2e94ea12c7" "all" "optional"  ; Missing in 1.22 except for Russian
	${Add} "misc\arx_russian.ttf"   "921561e83786efcd25f92147b60a13db" "all" "optional"  ; Missing in 1.22 except for Russian
	${Add} "misc\arx_taiwanese.ttf" "da59198061cef0761c6b2fca113f76f6" "all" "optional"  ; Missing in 1.22 except for Russian
	${Add} "misc\arx_base.ttf"      "921561e83786efcd25f92147b60a13db" "all" "optional"  ; Only in 1.22
	
	${Add} "misc\logo.bmp" "afff1099c01ffeb03b9a351f7b5966b6" ""     "optional" ; Retail
	${Add} "misc\logo.bmp" "aa3dfbd4bc9c863d10a0c5345ae5a4c9" "demo" "optional" ; Demo (Missing in Fishtank Demo)
	
	; 1.21 patch files (not included in demo versions)
	${Add} "graph\interface\misc\arkane.bmp"                  "afff1099c01ffeb03b9a351f7b5966b6" "patched" "patchonly"
	${Add} "graph\interface\misc\quit1.bmp"                   "41445d3792a1f8818d950aca47254488" "patched" "patchonly"
	${Add} "graph\obj3d\textures\fixinter_barrel.jpg"         "8419274acbff7346c3661b18d6aad6dc" "patched" "patchonly"
	${Add} "graph\obj3d\textures\fixinter_bell.bmp"           "5743b9047c9ad65540c318dfcc98123a" "patched" "patchonly"
	${Add} "graph\obj3d\textures\fixinter_metal_door.jpg"     "f246eff6b19c9c710313b4a4dce96a69" "patched" "patchonly"
	${Add} "graph\obj3d\textures\fixinter_public_notice.bmp"  "f81394abbb9006ce0950843b7909db33" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_bread.bmp"              "544448f8eedc912aa231a6a04fffb7c5" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_club.jpg"               "7e26c4199ddaca494c8b369294306b0b" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_long_sword.jpg"         "3a6196fe9b7666c7d80d82be06f6de86" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_mauld_sabre.jpg"        "18492c25ebac02f83e2f0ebda61ecb00" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_mauldsword.jpg"         "503a5c2f23668040c675aefdde6dbbe5" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_mirror.jpg"             "c0a22b4f7a7a6461da68206e94928637" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_ring_casting.bmp"       "348f9add709bacee08556d1f8cf10f3f" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_rope.bmp"               "ff05de281c8b380ee98f6e123d3d51cb" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_spell_sheet.jpg"        "024ccbb520020f92fba5a5a4f0270cea" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_torch2.jpg"             "027951899b4829599ca611010ea3484f" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_torch.jpg"              "9ada166f23ddcb775ac20836e752187e" "patched" "patchonly"
	${Add} "graph\obj3d\textures\item_zohark.bmp"             "cd206a4027f86c6e57b7710c94049efa" "patched" "patchonly"
	${Add} "graph\obj3d\textures\l7_dwarf_[wood]_board08.jpg" "79ccc81adb7c37b98f40b478ef1fccd4" "patched" "patchonly"
	${Add} "graph\obj3d\textures\l7_dwarf_[wood]_board80.jpg" "691611087b13d38ef02bb9dfd6a2518e" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_dog.bmp"                 "116bd374c14ae8c387a4da1899e1dca7" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_pig.bmp"                 "b7a4d0d3d230b2d1470176909004e38b" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_pig_dirty.bmp"           "76034d8d74056c8a982479d36321c228" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_rat_base.bmp"            "00c585ec9ebe8006d7ca72993de7b51b" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_rat_base_cm.bmp"         "cae38facbf77db742180b9e58d0eb42f" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_worm_body_part1.jpg"     "0b220bffaedc89fa663f08d12630c342" "patched" "patchonly"
	${Add} "graph\obj3d\textures\npc_worm_body_part2.bmp"     "20797cb78f6393a0fb5405969ba9f805" "patched" "patchonly"
	${Add} "graph\obj3d\textures\[wood]_light_door.jpg"       "00d0b018e995e7d013d6e52e92126901" "patched" "patchonly"
	
	; 1.22 patch files (not included in demo versions)
	${Add} "localisation\presence.ini"          "d1a4401d08502318371c47f80b175e13" "patched" "optional"
	${Add} "localisation\snd_armor.ini"         "4fcc39ad0f26c98d0faae69a4b95c094" "patched" "optional"
	${Add} "localisation\snd_material.ini"      "ff8a52f0579d8bfa04c8028f8e8f12ef" "patched" "optional"
	${Add} "localisation\snd_other.ini"         "ffe2077e85d226300bebd3d0021618cf" "patched" "optional"
	${Add} "localisation\snd_step.ini"          "9943481df910c6a0b94390015ce0c8c7" "patched" "optional"
	${Add} "localisation\snd_weapon.ini"        "0d42bedce8f4116ad6126e66394b9dec" "patched" "optional"
	${Add} "localisation\ucredits_chinese.txt"  "36de88578c05954cf5e8ea42a5a6df2f" "patched" "optional"
	${Add} "localisation\ucredits_deutsch.txt"  "ebd870da9bb68c024af84a18c4d5cf3e" "patched" "optional"
	${Add} "localisation\ucredits_english.txt"  "eba2044744c9a1539d154b9c4c033469" "patched" "optional"
	${Add} "localisation\ucredits_francais.txt" "f98b60af3d7e81bc24e945a2debd6cb6" "patched" "optional"
	${Add} "localisation\ucredits_italiano.txt" "36de88578c05954cf5e8ea42a5a6df2f" "patched" "optional"
	${Add} "localisation\ucredits_russian.txt"  "36de88578c05954cf5e8ea42a5a6df2f" "patched" "optional"
	${Add} "localisation\utext_francais.ini"    "b10b041ff8eec01e3c28c5bc637ff15a" "patched" "optional"
	
	; Optional files (included in 1.21 patch, but we don't care about them)
	${Add} "misc\logo.avi" "63ed31a4eb3d226c23e58cfaa974d484" "all" "optional" ; Retail
	${Add} "manual.pdf"    "7a6038e0397e2319aea5d8dc408d5da8" "all" "optional" ; Retail
	${Add} "map.pdf"       "3502c76227df6bbd8637d5355e270cc2" "all" "optional" ; Retail
	
	; Files only in the Fishtank demo
	${Add} "misc\albr55w.ttf" "cd2f48c60f10aa1b75354bbe0c7c9fed" "all" "optional" ; Fishtank Demo
	${Add} "misc\vineritc.ttf" "83e5ac371473d9693a6ad28c323c3cf8" "all" "optional" ; Fishtank Demo
	${Add} "misc\fishtank.avi" "88c622395f6632b850adeba530db51b4" "all" "optional" ; Fishtank Demo
	
	!undef Add
	
	Call FindArxFatalisData
	
FunctionEnd

;------------------------------------------------------------------------------
; Functions to locate existing Arx Fatalis installs

Function FindArxInDirectory
	
	Exch $0 ; Multiuser
	Exch 2
	Exch $2 ; Directory
	Exch
	Exch $1 ; Store
	Push $3
	
	${NormalizePath} "$2" $2
	${If} $2 != ""
		${Map.Get} $3 ArxFatalisLocationInfo "$2"
		${If} "$3" == __NULL
		${AndIf} ${FileExists} "$2\data.pak"
			${List.Add} ArxFatalisLocations "$2"
			${Map.Set} ArxFatalisLocationInfo "$2" "$0:$1"
		${EndIf}
	${EndIf}
	
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro FindArxInDirectory Multiuser Store Directory
	Push "${Directory}"
	Push "${Store}"
	Push "${Multiuser}"
	Call FindArxInDirectory
!macroend

!define FindArxInDirectory '!insertmacro FindArxInDirectory'

!macro FindArxInProgramFiles Store Subdir
	${FindArxInDirectory} ${MU_SYSTEM} "${Store}" "$PROGRAMFILES64\${Subdir}"
	${FindArxInDirectory} ${MU_SYSTEM} "${Store}" "$PROGRAMFILES32\${Subdir}"
	${FindArxInDirectory} ${MU_USER} "${Store}" "$UserProgramFiles\${Subdir}"
	${FindArxInDirectory} ${MU_USER} "${Store}" "$LOCALAPPDATA\Programs\${Subdir}"
!macroend

!define FindArxInProgramFiles '!insertmacro FindArxInProgramFiles'

Function FindArxInPossiblyQuotedDirectory
	
	Exch $0 ; Multiuser
	Exch 3
	Exch $1 ; Subdir
	Exch 2
	Exch $2 ; Directory
	Exch
	Exch $3 ; Store
	Push $4
	Push $5
	
	; Remove quotes from quoted values
	StrCpy $4 $2 1
	StrCpy $5 $2 1 -1
	${If} $4 == "$\""
	${AndIf} $5 == "$\""
		StrCpy $2 $2 -1 1
	${EndIf}
	
	${FindArxInDirectory} "$0" "$3" "$2$1"
	
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro FindArxInPossiblyQuotedDirectory Multiuser Store Directory Subdir
	Push "${Subdir}"
	Push "${Directory}"
	Push "${Store}"
	Push "${Multiuser}"
	Call FindArxInPossiblyQuotedDirectory
!macroend

!define FindArxInPossiblyQuotedDirectory '!insertmacro FindArxInPossiblyQuotedDirectory'

Function FindArxInRegistry
	
	Exch $0 ; RegSubKey
	Exch 3
	Exch $1 ; Store
	Exch 2
	Exch $2 ; Subdir
	Exch
	Exch $3 ; RegValue
	Push $4
	
	ReadRegStr $4 HKCU "Software\$0" "$3"
	${If} $4 != ""
		${FindArxInPossiblyQuotedDirectory} ${MU_USER} "$1" "$4" "$2"
	${EndIf}
	
	${If} ${RunningX64}
		
		ReadRegStr $4 HKCU "Software\Wow6432Node\$0" "$3"
		${If} $4 != ""
			${FindArxInPossiblyQuotedDirectory} ${MU_USER} "$1" "$4" "$2"
		${EndIf}
		
	${EndIf}
	
	ReadRegStr $4 HKLM "Software\$0" "$3"
	${If} $4 != ""
		${FindArxInPossiblyQuotedDirectory} ${MU_SYSTEM} "$1" "$4" "$2"
	${EndIf}
	
	${If} ${RunningX64}
		
		ReadRegStr $4 HKLM "Software\Wow6432Node\$0" "$3"
		${If} $4 != ""
			${FindArxInPossiblyQuotedDirectory} ${MU_SYSTEM} "$1" "$4" "$2"
		${EndIf}
		
	${EndIf}
	
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro FindArxInRegistry RegSubKey RegValue Subdir Store
	Push "${Store}"
	Push "${Subdir}"
	Push "${RegValue}"
	Push "${RegSubKey}"
	Call FindArxInRegistry
!macroend

!define FindArxInRegistry '!insertmacro FindArxInRegistry'

!define WINDOWS_STORE_CACHE "Software\Microsoft\Windows\CurrentVersion\AppModel\StateRepository\Cache"

Function FindArxWindowsApp
	
	Exch $0 ; DefaultLanguage
	Push $1
	Push $2
	Push $3
	Push $4
	
	StrCpy $1 0
	${Do}
		EnumRegKey $2 HKLM "${WINDOWS_STORE_CACHE}\PackageFamily\Index\PackageFamilyName\${ARX_WINDOWS_PACKAGE}" $1
		${If} $2 == ""
			${Break}
		${EndIf}
		StrCpy $3 0
		${Do}
			EnumRegKey $4 HKLM "${WINDOWS_STORE_CACHE}\Package\Index\PackageFamily\$2" $3
			${If} $4 == ""
				${Break}
			${EndIf}
			ReadRegStr $4 HKLM "${WINDOWS_STORE_CACHE}\Package\Data\$4" "MutableLocation"
			${If} $4 != ""
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\$0"
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\EN"
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\DE"
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\FR"
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\ES"
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\IT"
				${FindArxInDirectory} ${MU_SYSTEM} "windows" "$4\RU"
			${EndIf}
			IntOp $3 $3 + 1
		${Loop}
		IntOp $1 $1 + 1
	${Loop}
	
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro FindArxWindowsApp DefaultLanguage
	Push "${DefaultLanguage}"
	Call FindArxWindowsApp
!macroend

!define FindArxWindowsApp '!insertmacro FindArxWindowsApp'

; Call FindArxFatalisData
; Fills the ArxFatalisLocations list with installed Arx Fatalis locations and stores metadata
; about that location that can be queried using ${GetArxFatalisInstallMode} or ${GetArxFatalisStore}.
Function FindArxFatalisData
	
	Push $0
	
	GetKnownFolderPath $UserProgramFiles ${FOLDERID_UserProgramFiles}
	
	${List.Create} ArxFatalisLocations
	${Map.Create} ArxFatalisLocationInfo
	
	; GOG
	${FindArxInRegistry} "GOG.com\GOGARXFATALIS" "PATH" "" "gog"
	${FindArxInRegistry} "GOG.com\Games\${ARX_GOG_GAMEID}" "path" "" "gog"
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\${ARX_GOG_GAMEID}_is1" "InstallLocation" "" "gog"
	
	; Steam
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\Steam App ${ARX_STEAM_APPID}" "InstallLocation" "" "steam"
	
	; Bethesda.net Launcher
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\Arx Fatalis" "Path" "" "bethesda"
	
	; Normal install
	${FindArxInRegistry} "Arkane Studios\Installed Apps\Arx Fatalis" "Folder" "" ""
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\{96443F45-13E2-11D6-AC87-00D0B7A9E540}" "InstallLocation" "" ""
	
	; 1.21 patch
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\{171251E0-4EED-4EA1-A46D-3213A226F2B3}_is1" "InstallLocation" "" ""
	
	; Microsoft Store
	System::Call 'KERNEL32::GetUserDefaultLocaleName(t.r0, i${NSIS_MAX_STRLEN})i.n'
	StrCpy $0 "$0" 2
	${FindArxWindowsApp} "$0"
	
	; Fallback: probe standard install locations
	
	; GOG
	${FindArxInRegistry} "GOG.com\GalaxyClient\paths" "client" "\Games\Arx Fatalis" "gog"
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\{7258BA11-600C-430E-A759-27E2C691A335}_is1" "InstallLocation" "\Games\Arx Fatalis" "gog"
	${FindArxInProgramFiles} "gog" "GOG Galaxy\Games\Arx Fatalis"
	${FindArxInProgramFiles} "gog" "GOG.com\Arx Fatalis"
	${FindArxInDirectory} ${MU_UNKNOWN} "gog" "C:\GOG Games\Arx Fatalis"
	
	; Steam
	${FindArxInRegistry} "Valve\Steam" "InstallPath" "\steamapps\common\Arx Fatalis" "steam"
	${FindArxInProgramFiles} "steam" "Steam\steamapps\common\Arx Fatalis"
	
	; Bethesda.net Launcher
	${FindArxInRegistry} "Bethesda Softworks\Bethesda.net" "installLocation" "\games\Arx Fatalis" "bethesda"
	${FindArxInRegistry} "Microsoft\Windows\CurrentVersion\Uninstall\{3448917E-E4FE-4E30-9502-9FD52EABB6F5}_is1" "InstallLocation" "\games\Arx Fatalis" "bethesda"
	${FindArxInProgramFiles} "bethesda" "bethesda.net launcher\games\Arx Fatalis"
	
	; Microsoft Store
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\$0"
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\EN"
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\DE"
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\FR"
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\ES"
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\IT"
	${FindArxInDirectory} ${MU_SYSTEM} "windows" "$PROGRAMFILES64\ModifiableWindowsApps\Arx Fatalis (PC)\RU"
	
	; Original
	${FindArxInProgramFiles} "" "Fishtank Interactive\Arx Fatalis"
	${FindArxInProgramFiles} "" "JoWood\Arx Fatalis"
	
	; Demo
	${FindArxInProgramFiles} "" "Arx Fatalis Demo"
	
	Pop $0
	
FunctionEnd

!macro GetFirstArxFatalisInstallLocation Result
	${List.Count} ${Result} ArxFatalisLocations
	${If} ${Result} == 0
		StrCpy ${Result} ""
	${Else}
		${List.Get} ${Result} ArxFatalisLocations 0
	${EndIf}
!macroend

; ${GetFirstArxFatalisInstallLocation} Result
!define GetFirstArxFatalisInstallLocation '!insertmacro GetFirstArxFatalisInstallLocation'

Function GetArxFatalisInstallMode
	
	Exch $0 ; Path
	Push $1
	
	${Map.Get} $1 ArxFatalisLocationInfo "$0"
	${If} $1 == __NULL
		
		${IsSubdirectory} "$PROGRAMFILES64" "$0" $1
		${If} $1 == 1
			StrCpy $0 "AllUsers"
		${Else}
			${IsSubdirectory} "$PROGRAMFILES32" "$0" $1
			${If} $1 == 1
				StrCpy $0 "AllUsers"
			${Else}
				${IsSubdirectory} "$UserProgramFiles" "$0" $1
				${If} $1 == 1
					StrCpy $0 "CurrentUser"
				${Else}
					${IsSubdirectory} "$LOCALAPPDATA" "$0" $1
					${If} $1 == 1
						StrCpy $0 "CurrentUser"
					${Else}
						${IsSubdirectory} "$PROFILE" "$0" $1
						${If} $1 == 1
							StrCpy $0 "CurrentUser"
						${Else}
							StrCpy $0 ""
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}
		
	${Else}
		
		StrCpy $0 "$1" 1
		${If} $0 == ${MU_SYSTEM}
			StrCpy $0 "AllUsers"
		${ElseIf} $0 == ${MU_USER}
			StrCpy $0 "CurrentUser"
		${Else}
			StrCpy $0 ""
		${EndIf}
		
	${EndIf}
	
	Pop $1
	Exch $0
	
FunctionEnd

!macro GetArxFatalisInstallMode Path MultiuserResult
	Push "${Path}"
	Call GetArxFatalisInstallMode
	Pop ${MultiuserResult}
!macroend

; ${GetArxFatalisInstallMode} Path MultiuserResult StoreResult
; Gets information about the Arx Fatalis install at the given Path.
; The path should be normalized using ${NormalizePath} like those listed in ArxFatalisLocations.
; MultiuserResult will contain if the path is a system or user install: "AllUsers", "CurrentUser" or ""
; Paths not belonging to any store will return an empty string.
!define GetArxFatalisInstallMode '!insertmacro GetArxFatalisInstallMode'

!macro GetArxFatalisStore Path StoreResult
	${Map.Get} ${StoreResult} ArxFatalisLocationInfo "${Path}"
	${If} ${StoreResult} == __NULL
		StrCpy ${StoreResult} ""
	${Else}
		StrCpy ${StoreResult} "${StoreResult}" ${NSIS_MAX_STRLEN} 2
	${EndIf}
!macroend

; ${GetArxFatalisStore} Path StoreResult
; Gets information about the Arx Fatalis install at the given Path.
; The path should be normalized using ${NormalizePath} like those listed in ArxFatalisLocations.
; StoreResult will contain the store the path belongs to: "gog", "steam", "bethesda" or "windows"
; Paths not belonging to any store will return an empty string.
!define GetArxFatalisStore '!insertmacro GetArxFatalisStore'

Function IdentifyArxFatalisData
	
	Exch $0 ; Path
	Push $1
	Push $2
	Push $3
	
	${IfNot} ${FileExists} "$0\data.pak"
		
		StrCpy $1 ""
		
	${Else}
		
		StrCpy $1 "$0\loc.pak"
		${IfNot} ${FileExists} "$1"
			StrCpy $1 "$0\loc_default.pak"
		${EndIf}
		md5dll::GetMD5File "$1"
		Pop $3
		${Map.Get} $1 ArxFatalisChecksums "loc.pak:$3"
		
		md5dll::GetMD5File "$0\data2.pak"
		Pop $3
		${Map.Get} $2 ArxFatalisChecksums "data2.pak:$3"
		
		${If} $1 != $2
			
			${If} $1 == __NULL
				; loc.pak is unknown → use demoness of data2.pak but mark as unpatched for non-demo
				StrCpy $1 "$2"
				${If} $1 == "patched"
					StrCpy $1 "unpatched"
				${EndIf}
			${ElseIf} $2 == __NULL
				; data2.pak is unknown → use demoness of data.pak but mark as unpatched for non-demo
				${If} $1 == "patched"
					StrCpy $1 "unpatched"
				${EndIf}
			${ElseIf} $1 == "patched"
			${AndIf} $2 == "unpatched"
				StrCpy $1 "unpatched"
			${ElseIf} $1 != "unpatched"
			${OrIf} $2 != "patched"
				; Mixed reail + demo
				StrCpy $1 "unknown"
			${EndIf}
			
		${ElseIf} $1 == __NULL
			
			; Fallback if both loc.pak and data2.pak are unknown: determine demoness from sfx.pak
			md5dll::GetMD5File "$0\sfx.pak"
			Pop $3
			${Map.Get} $1 ArxFatalisChecksums "sfx.pak:$3"
			${If} $1 == __NULL
				StrCpy $1 "unknown"
			${ElseIf} $1 != "demo"
				StrCpy $1 "unpatched"
			${EndIf}
			
		${EndIf}
		
	${EndIf}
	
	Pop $3
	Pop $2
	Exch
	Pop $0
	Exch $1
	
FunctionEnd

!macro IdentifyArxFatalisData Path Result
	Push "${Path}"
	Call IdentifyArxFatalisData
	Pop ${Result}
!macroend

; ${IdentifyArxFatalisData} Path Result
; Gets information about the type of Arx Fatalis data at the given Path.
; Possible values written to Result are "demo", "unpatched", "patched" or "unknown".
; If there is not data at all, an emtpy string is returned in Result.
!define IdentifyArxFatalisData '!insertmacro IdentifyArxFatalisData'

!macro GetPakFileDefault Input Output
	StrCpy ${Output} "${Input}" 4 -4
	${If} ${Output} == ".pak"
		StrCpy ${Output} "${Input}" -4
		StrCpy ${Output} "${Output}_default.pak"
	${Else}
		StrCpy ${Output} ""
	${EndIf}
!macroend

!define GetPakFileDefault '!insertmacro GetPakFileDefault'

Function GetArxFatalisDataSize
	
	Exch $0 ; Path
	Push $1
	Push $2
	Push $3
	Push $4
	Push $5
	
	StrCpy $4 0
	StrCpy $5 0
	
	${List.Count} $1 ArxFatalisFiles
	${DoWhile} $1 > 0
		IntOp $1 $1 - 1
		${List.Get} $2 ArxFatalisFiles $1
		
		${GetFileSize} "$0\$2" $3
		IntOp $4 $4 + $3
		${If} $3 > 0
			IntOp $5 $5 + 1
		${EndIf}
		
		${GetPakFileDefault} "$2" $3
		${If} $3 != ""
			${GetFileSize} "$0\$3" $3
			IntOp $4 $4 + $3
			${If} $3 > 0
				IntOp $5 $5 + 1
			${EndIf}
		${EndIf}
		
	${Loop}
	
	StrCpy $0 $4
	StrCpy $1 $5
	
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Exch $1
	Exch
	Exch $0
	
FunctionEnd

!macro GetArxFatalisDataSize Path SizeResult CountResult
	Push "${Path}"
	Call GetArxFatalisDataSize
	Pop ${SizeResult}
	Pop ${CountResult}
!macroend

; ${GetArxFatalisDataSize} Path Result
; Calculate the size of all Arx Fatalis data in Path and store the result in Result
!define GetArxFatalisDataSize '!insertmacro GetArxFatalisDataSize'

Function ArxFatalisDataProcess
	
	Exch $0 ; Path
	Exch
	Exch $1 ; Mode
	Push $2
	Push $3
	Push $4
	
	${List.Count} $2 ArxFatalisFiles
	${DoWhile} $2 > 0
		IntOp $2 $2 - 1
		${List.Get} $3 ArxFatalisFiles $2
		${GetPakFileDefault} "$3" $4
		${DoWhile} $3 != ""
			${UninstallLogMark} "$1" "$0\$3"
			${GetDirectory} "$3" $3
		${Loop}
		${If} $4 != ""
			${UninstallLogMark} "$1" "$0\$4"
		${EndIf}
	${Loop}
	
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
FunctionEnd

!macro ArxFatalisDataProcess Mode Path
	Push "${Mode}"
	Push "${Path}"
	Call ArxFatalisDataProcess
!macroend

; ${OrphanArxFatalisData} Path
; Mark Arx Fatalis data as not owned by this installer
!define OrphanArxFatalisData '!insertmacro ArxFatalisDataProcess "orphan"'

; ${KeepArxFatalisData} Path
; Mark Arx Fatalis data as owned by this installer and not to be cleaned
!define KeepArxFatalisData '!insertmacro ArxFatalisDataProcess "keep"'

!macro CopyArxFatalisDataFile Path
	
	DetailPrint "$(ARX_COPY_DATA_FILE) ${Path}"
	
	${UninstallLogAdd} "$1\${Path}"
	
	${Do}
		
		; Try to rename the file if we own the old location
		${Map.Get} $7 UninstallLogInfo "$0\${Path}"
		${If} $7 == "old"
			ClearErrors
			Rename "$0\${Path}" "$1\${Path}"
			${IfNot} ${Errors}
				${Break}
			${EndIf}
		${EndIf}
		
		; Otherwise, copy it
		ClearErrors
		CopyFiles /SILENT "$0\${Path}" "$1$5"
		${IfNot} ${Errors}
			${Break}
		${EndIf}
		
		${If} ${Cmd} `MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION "$(ARX_COPY_DATA_FILE_ERROR)$\n$\n${Path}" /SD IDIGNORE IDABORT abort IDIGNORE`
			${Break}
		${EndIf}
		
	${Loop}
	
	${ProgressBarFile} "$0\${Path}"
	
!macroend

Function CopyArxFatalisData
	
	Exch $0 ; Source
	Exch
	Exch $1 ; Dest
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6
	Push $7
	
	DetailPrint "$(ARX_COPY_DATA_DIR) $0"
	
	${List.Count} $3 ArxFatalisFiles
	StrCpy $2 0
	${DoWhile} $2 < $3
		${List.Get} $4 ArxFatalisFiles $2
		
		${GetDirectory} "\$4" $5
		${GetPakFileDefault} "$4" $6
		
		StrCpy $6 "$4" 4 -4
		${If} $6 == ".pak"
			StrCpy $6 "$4" -4
			StrCpy $6 "$6_default.pak"
		${Else}
			StrCpy $6 ""
		${EndIf}
		
		${If} ${FileExists} "$0\$4"
			${CreateDirectoryRecursive} "$1" "$5"
			!insertmacro CopyArxFatalisDataFile "$4"
			${If} $6 != ""
			${AndIf} ${FileExists} "$0\$6"
				!insertmacro CopyArxFatalisDataFile "$6"
			${EndIf}
		${ElseIf} $6 != ""
		${AndIf} ${FileExists} "$0\$6"
			${CreateDirectoryRecursive} "$1" "$5"
			!insertmacro CopyArxFatalisDataFile "$6"
		${EndIf}
		
		IntOp $2 $2 + 1
	${Loop}
	
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	
	Return
	
abort:
	
	Abort
	
FunctionEnd

!macro CopyArxFatalisData Source Dest
	Push "${Dest}"
	Push "${Source}"
	Call CopyArxFatalisData
!macroend

; ${CopyArxFatalisData} Source Dest
; Copy all existing Arx Fatalis data files from Source to Dest
!define CopyArxFatalisData '!insertmacro CopyArxFatalisData'

!macro VerifyArxFatalisDataFile Path
	
	DetailPrint "$(ARX_VERIFY_DATA_FILE) ${Path}"
	StrCpy $R0 1
	
	md5dll::GetMD5File "$0\${Path}"
	Pop $6
	${Map.Get} $5 ArxFatalisChecksums "$3:$6"
	${If} $5 == __NULL
	${OrIf} $5 == "unpatched"
		
		${If} $5 == "unpatched"
			DetailPrint "  $(ARX_VERIFY_DATA_UNPATCHED) $6"
		${Else}
			DetailPrint "  $(ARX_VERIFY_DATA_UNKNOWN) $6"
		${EndIf}
		StrCpy $R4 1
		
		${Map.Get} $6 ArxFatalisFileInfo "$3"
		${If} $6 == "patch"
		${OrIf} $6 == "patchonly"
			StrCpy $R1 1
		${EndIf}
		
	${ElseIf} $5 == "all"
		DetailPrint "  $(ARX_VERIFY_DATA_VALID) $6"
		; present in both demo and non-demo
	${ElseIf} $5 == "demo"
		DetailPrint "  $(ARX_VERIFY_DATA_VALID_DEMO) $6"
		StrCpy $R2 1
	${Else}
		DetailPrint "  $(ARX_VERIFY_DATA_VALID_RETAIL) $6"
		StrCpy $R3 1
	${EndIf}
	
	${ProgressBarFile} "$0\${Path}"
	
!macroend

Function VerifyArxFatalisData
	
	Exch $0 ; Path
	Push $1
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	
	DetailPrint "$(ARX_VERIFY_DATA_DIR) $0"
	
	StrCpy $R0 0 ; found any files
	StrCpy $R1 0 ; any missing/invalid files were patchable
	StrCpy $R2 0 ; found any demo files
	StrCpy $R3 0 ; found any non-demo files
	StrCpy $R4 0 ; found any invalid files
	
	${List.Create} VerifyArxFatalisDataMissingCore
	${List.Create} VerifyArxFatalisDataMissingPatch
	
	${List.Count} $2 ArxFatalisFiles
	StrCpy $1 0
	${DoWhile} $1 < $2
		${List.Get} $3 ArxFatalisFiles $1
		
		${GetPakFileDefault} "$3" $4
		${If} $4 != ""
		${AndIf} ${FileExists} "$0\$4"
			!insertmacro VerifyArxFatalisDataFile "$4"
			StrCpy $4 1
		${Else}
			StrCpy $4 0
		${EndIf}
		
		${If} ${FileExists} "$0\$3"
			!insertmacro VerifyArxFatalisDataFile "$3"
			StrCpy $4 1
		${EndIf}
		
		${If} $4 == 0
			
			${Map.Get} $4 ArxFatalisFileInfo "$3"
			${If} $4 != "optional"
				${If} $4 == "patchonly"
					; File is allowed to be absent in demo data
					${List.Add} VerifyArxFatalisDataMissingPatch "$3"
					StrCpy $R1 1
				${ElseIf} $4 == "patch"
					${List.Add} VerifyArxFatalisDataMissingCore "$3"
					StrCpy $R1 1
				${Else}
					${List.Add} VerifyArxFatalisDataMissingCore "$3"
				${EndIf}
			${EndIf}
			
		${EndIf}
		
		IntOp $1 $1 + 1
	${Loop}
	
	${If} $R2 == 0
		${List.Concat} VerifyArxFatalisDataMissingCore VerifyArxFatalisDataMissingPatch
	${EndIf}
	
	${List.Count} $2 VerifyArxFatalisDataMissingCore
	StrCpy $1 0
	${DoWhile} $1 < $2
		${List.Get} $3 VerifyArxFatalisDataMissingCore $1
		DetailPrint "$(ARX_VERIFY_DATA_MISSING) $3"
		IntOp $1 $1 + 1
	${Loop}
	
	${List.Destroy} VerifyArxFatalisDataMissingCore
	${List.Destroy} VerifyArxFatalisDataMissingPatch
	
	${If} $R0 == 0
		StrCpy $0 "nodata"
	${ElseIf} $R2 != 0
	${AndIf} $R3 != 0
		StrCpy $0 "mixed"
	${ElseIf} $R2 == 0
	${AndIf} $R1 != 0
		StrCpy $0 "patchable"
	${ElseIf} $2 != 0
	${OrIf} $R4 != 0
		StrCpy $0 "invalid"
	${Else}
		StrCpy $0 ""
	${EndIf}
	
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	
FunctionEnd

!macro VerifyArxFatalisData Path Result
	Push "${Path}"
	Call VerifyArxFatalisData
	Pop ${Result}
!macroend

; ${VerifyArxFatalisData} Path Result
!define VerifyArxFatalisData '!insertmacro VerifyArxFatalisData'

Function LaunchArxFatalisInStore
	
	Exch $0 ; Store
	
	ClearErrors
	
	${Switch} $0
		
		${Case} "steam"
			ExecShell "open" "steam://run/${ARX_STEAM_APPID}"
			${Break}
		
		${Case} "bethesda"
			ExecShell "open" "bethesdanet://run/${ARX_BETHESDA_LAUNCHID}"
			${Break}
		
		${Case} "windows"
			ExecShell "open" "shell:AppsFolder\${ARX_WINDOWS_APPID}"
			${Break}
		
		${Default}
			Goto error
		
	${EndSwitch}
	
	IfErrors error
	
	Pop $0
	Push 1
	Return
	
error:
	
	Pop $0
	Push 0
	
FunctionEnd

!macro LaunchArxFatalisInStore Store Result
	Push "${Store}"
	Call LaunchArxFatalisInStore
	Pop ${Result}
!macroend

; ${LaunchArxFatalisInStore} Store Result
; Launch Arx Fatalis via the given store app. Result will contain 1 on success and 0 on error.
!define LaunchArxFatalisInStore '!insertmacro LaunchArxFatalisInStore'

Function LaunchArxFatalis
	
	Exch $0 ; Path
	Push $1
	
	${NormalizePath} "$0" $0
	
	${GetArxFatalisStore} "$0" $1
	
	${LaunchArxFatalisInStore} "$1" $1
	
	${If} $1 == 0
		StrCpy $1 "$OUTDIR"
		SetOutPath "$0"
		Exec "$\"$0\arx.exe$\""
		SetOutPath "$OUTDIR"
	${EndIf}
	
	Pop $1
	Pop $0
	
FunctionEnd

!macro LaunchArxFatalis Path
	Push "${Path}"
	Call LaunchArxFatalis
!macroend

; ${LaunchArxFatalis} Path
; Launch Arx Fatalis at the given path, via the respective store app if it is a store install.
!define LaunchArxFatalis '!insertmacro LaunchArxFatalis'

!endif ; ArxFatalisData
