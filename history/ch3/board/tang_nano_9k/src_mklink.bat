@echo off
set target_dir=%cd%\ch3\src

set source_dir=%cd%\..\..\src
for %%i in ("%source_dir%\*.sv")  do (mklink "%target_dir%\%%~nxi" "%%i")

set source_dir=%cd%\..\..\mem
for %%i in ("%source_dir%\*.mem") do (mklink "%target_dir%\%%~nxi" "%%i")

set source_dir=%cd%
for %%i in ("%source_dir%\*.sv")  do (mklink "%target_dir%\%%~nxi" "%%i")

set source_dir=%cd%
for %%i in ("%source_dir%\*.cst") do (mklink "%target_dir%\%%~nxi" "%%i")
