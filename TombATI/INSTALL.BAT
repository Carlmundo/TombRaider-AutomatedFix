cd "%~dp0"
vc_redist.x86.exe
TombRaiderImporter.exe
CALL shortcutJS.bat -linkfile "%HOMEDRIVE%%HOMEPATH%\Desktop\TombATI.lnk" -target "%CD%\TombATI.exe" -workingdirectory "%CD%" -iconlocation "%CD%\TombATI.ico"
CALL shortcutJS.bat -linkfile "%HOMEDRIVE%%HOMEPATH%\Desktop\TombUB.lnk" -target "%CD%\Tombub.exe" -workingdirectory "%CD%" -iconlocation "%CD%\TombATI.ico"
CALL shortcutJS.bat -linkfile "%HOMEDRIVE%%HOMEPATH%\Desktop\TombATI Configure.lnk" -target "%CD%\TombATIConfigure.exe" -workingdirectory "%CD%" -iconlocation "%CD%\TombATI.ico"
