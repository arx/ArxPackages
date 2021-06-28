@echo off
rem This file overwrites arx.bat shipped with the 1.22 update of Arx Fatalis
rem in order to disable the __COMPAT_LAYER workaround which AL doesn't need.
bin\x86\arxtool.exe hideconsole
arx.exe %*
