@echo off
setlocal enabledelayedexpansion

REM Check if ffmpeg is installed
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo ffmpeg is not installed or not in the system PATH.
    exit /b 1
)

REM Create the dump-subs directory if it doesn't exist
if not exist "dump-subs" (
    mkdir "dump-subs"
)

REM Loop through all .mkv video files in the current directory
for %%f in (*.mkv) do (
    set "filename=%%~nf"
    
    REM Extract the Vietnamese subtitle (index 1)
    ffmpeg -i "%%f" -map 0:s:1 "dump-subs\%%~nf.ass"
    if errorlevel 1 (
        echo Failed to extract Vietnamese subtitle from %%f
    ) else (
        echo Extracted Vietnamese subtitle from %%f
    )
)

echo Subtitle extraction completed.