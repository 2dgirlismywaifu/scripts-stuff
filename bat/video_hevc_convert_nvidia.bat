@echo off
setlocal enabledelayedexpansion

set input_dir=%~dp0
set output_dir=%input_dir%hevc
if not exist "%output_dir%" mkdir "%output_dir%"

REM Create a list of files that are already in HEVC format
set hevc_list=%input_dir%hevc_list.txt
if exist "%hevc_list%" del "%hevc_list%"

for %%i in (*.mkv) do (
    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 "%%i" | findstr /c:"hevc" >nul
    if !errorlevel! equ 0 (
        echo %%i >> "%hevc_list%"
    )
)

REM Convert files that are not in HEVC format
for %%i in (*.mkv) do (
    setlocal disabledelayedexpansion
    findstr /c:"%%i" "%hevc_list%" >nul
    if !errorlevel! equ 1 (
        echo Converting: %%i
        ffmpeg -hwaccel cuvid -hwaccel_output_format cuda -i "%%i" -c:v hevc_nvenc -rc constqp -qp 28 -tune hq -multipass fullres -map 0 -c:a copy -c:s copy "%output_dir%\%%~ni.mkv"
        if !errorlevel! neq 0 (
            echo Failed to convert: %%i
        )
    ) else (
        echo Skipping: %%i already HEVC
    )
)

echo Conversion complete!
pause