@echo off

REM  Requires environment variables to be set:  %Target%  %SavedVariables%  %Client%
REM  The parameters  %1..%n  are the account folder names to process.
REM %SavedVariables%  is the name of the common SavedVariables folder, relative to the account folder. Default:  +SavedVariables

if  %SavedVariables%*==*  set SavedVariables="+SavedVariables"
echo Target=%Target%  Client=%Client%  SymlinkFiles=%SymlinkFiles%  SavedVariables=%SavedVariables%
if %Client%*==*  echo  Set a Client:  folder path of the game client that will use these accounts
if %1*==* (
	echo Set a Target:  sv / delsv / addons / deladdons / realm / delrealm / sett
	echo.
	echo    "sv"        -- create account links to +SavedVariables
	echo    "delsv"     -- delete account links to +SavedVariables
	echo    "addons"    -- create hard links to AddOns.txt
	echo    "deladdons" -- delete links to AddOns.txt
	echo    "realm"     -- create links to character folders in realm folder
	echo    "delrealm"  -- delete links to character folders in realm folder
	echo    "sett"      -- copy settings to account and character folders - from %AccountCommon% and %CharacterCommon% folders
	echo.
)

if %RealmFolder%*==*      set RealmFolder=+%Realm%
if %AccountCommon%*==*    set AccountCommon=+Common\account
if %CharacterCommon%*==*  set CharacterCommon=+Common\character



REM Run as normal user it can only make hard links (/h) for files and junctions (/j) for directories.
set admin=
set dirLink=/j
set dirPrefix=
set fileLink=/h
set filePrefix=

whoami /groups | find "S-1-16-12288" >nul && (
	REM Run as elevated user (admin rights) it can make symbolic links (default) for files and for directories (/d).
	REM Symbolic links are relative therefore root folders can be moved around and symlink with both source and target inside the root folder will remain functional,
	REM whereas junctions would break, as those target an absolute path which changed when moving the root folder.
	set admin=1
	set dirLink=/d
	set dirPrefix=..\
	if %SymlinkFiles%*==1* (
		set fileLink=
		set filePrefix=..\
	)

	REM Hard links are better for files:  all links can be seen in properties  and  the files can be moved around (anywhere inside a partition) safely, without breaking the link.
	REM The benefit of symlinks could be:  linking to another partition (not used in this case)  and  in case the symlink is reachable at different paths in a partition
	REM - as a result of being inside a linked folder - a symlink like ..\..\WTF\Account\AddOns.txt  will link to different files depending on how it was reached:
	REM The same symlink in  Tauri\Interface\AddOns will link to Tauri\WTF\Account\AddOns.txt  while in  Ashamane\Interface\AddOns will link to Ashamane\WTF\Account\AddOns.txt
	REM This is useful to link enabled addons list to the AddOns folder for easy editing while working on addons. Yes, probably i'm the only one doing it.
	REM So file symlinks are beneficial only in very specific use-cases. That one symlink is gona be made by hand, not this script.
	REM set fileLink=/h
	REM set filePrefix=
	REM
	REM Counter-reason:  git properly ignores symlinks, but happily commits multiple copies of hardlinked files. That's a definite benefit of symlinks, tho
	REM it depends only on the software's interpretation.
	
	echo Running elevated, makin' smooth symlinks.
	echo.
)



if %Target%*==all* (
	set Target=
	call :dotarget  delsv     %*
	call :dotarget  sv        %*
	call :dotarget  deladdons %*
	call :dotarget  addons    %*
	call :dotarget  delrealm  %*
	call :dotarget  realm     %*

) else (
	call :dotarget  %Target%  %*
)


:done

set Target=
set Client=
set SymlinkFiles=
set SavedVariables=
set Realm=
set RealmFolder=
set AccountCommon=
set CharacterCommon=

echo.
echo.
echo Finished.
echo.
pause
GOTO :eof




:once

if  %1*==sett* (
	if exist makelinks.log  del makelinks.log
)
if  %1*==addons* (
	REM Make the root Account\AddOns.txt a symlink to active Interface\AddOns folder. Needs admin privileges, will complain if not granted.
	if not exist "AddOns.txt"  mklink  "AddOns.txt" "%Client%\Interface\AddOns\AddOns.txt"
)
if  %1*==deladdons* (
	REM Delete AddOns.txt only as admin, so we can recreate it in a next execution.
	if %admin%*==1*  if exist "AddOns.txt"  del  "AddOns.txt"
)
goto :eof




:dotarget
call :once %1

:loop

if %2*==* GOTO :eof
call  :%1  %2
shift /2
GOTO :loop




:sv
	mklink %dirLink%  "%1\SavedVariables"		"%dirPrefix%%SavedVariables%"
	goto :eof


:delsv
	echo   rmdir  "%1\SavedVariables"
	if exist "%1\SavedVariables"  rmdir   "%1\SavedVariables"
	goto :eof


:addons
	mklink %fileLink%  "%1\AddOns.txt"			"%filePrefix%AddOns.txt"

	if  "%Realm%"==""  for /d %%b in ("%1\*") do  if not "%%b"=="%1\SavedVariables"  for /d %%c in ("%%b\*") do  (
		mklink %fileLink% "%%c\AddOns.txt"  %filePrefix%%filePrefix%%filePrefix%AddOns.txt
	)
	goto :eof


:deladdons
	echo   del   "%1\AddOns.txt"
	if exist "%1\AddOns.txt"  del   "%1\AddOns.txt"

	if  "%Realm%"==""  for /d %%b in ("%1\*") do  if not "%%b"=="%1\SavedVariables"  for /d %%c in ("%%b\*") do  (
		echo   del "%%c\AddOns.txt"
		if exist "%%c\AddOns.txt"  del "%%c\AddOns.txt"
	)
	goto :eof


:realm
	REM  %1 = <Account>    %%b = <Account>\<Realm>    %%c = <Account>\<Realm>\<Character>
	if  "%Realm%"==""  for /d %%b in ("%1\*") do  if not "%%b"=="%1\SavedVariables"  for /d %%c in ("%%b\*") do  (
		REM  %%r = <Realm>    %%s = <Character>
		for /F "tokens=2-3 delims=\" %%r IN ("%%c") DO (
			REM echo   mklink   %%r\%%s  --  %%c
			if not EXIST "%%r"  mkdir  "%%r"
			mklink %dirLink% "%%r\%%s" "%dirPrefix%%%c"
		)
	)

	if  not "%Realm%"==""  mklink %dirLink%  "%1\%Realm%"					"%dirPrefix%%RealmFolder%"
	goto :eof


:delrealm
	if  not "%Realm%"=="" (
		echo   rmdir    "%1\%Realm%"
		if exist "%1\%Realm%"  rmdir "%1\%Realm%"
	)
	REM  %1 = <Account>    %%b = <Account>\<Realm>    %%c = <Account>\<Realm>\<Character>
	if  "%Realm%"==""  for /d %%b in ("%1\*") do  if not "%%b"=="%1\SavedVariables"  for /d %%c in ("%%b\*") do  (
		REM  %%r = <Realm>    %%s = <Character>
		for /F "tokens=2-3 delims=\" %%r IN ("%%c") DO (
			echo   rmdir  "%%r\%%s"
			if exist  "%%r\%%s"  rmdir "%%r\%%s"
		)
	)
	goto :eof


:sett
	REM /XO : eXclude Older - if destination file exists and is the same date or newer than the source - don’t bother to overwrite it.
	echo   robocopy "%AccountCommon%"  "%1" /xo /log+:makelinks.log
	robocopy "%AccountCommon%"  "%1" /xo /log+:makelinks.log >nul

	REM for /d -> do it for all folders
	REM /S : Copy Subfolders.
	for /d %%b in ("%1\*") do  for /d %%c in ("%%b\*") do  (
		echo robocopy "%CharacterCommon%"  "%%c" /s /xo /log+:makelinks.log
		robocopy "%CharacterCommon%"  "%%c" /s /xo /log+:makelinks.log >nul
	)
	goto :eof




GOTO :eof

