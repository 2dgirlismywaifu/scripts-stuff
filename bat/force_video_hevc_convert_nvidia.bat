@echo off
set input_dir=%~dp0
set output_dir=%input_dir%hevc
if not exist "%output_dir%" mkdir "%output_dir%"

for %%i in (*.mkv) do (
    ffmpeg -hwaccel cuvid -hwaccel_output_format cuda -i "%%i" -c:v hevc_nvenc -rc constqp -qp 28 -tune hq -multipass fullres -map 0 -c:a copy -c:s copy "%output_dir%\%%~ni.mkv"
)

echo Conversion complete!
pause
