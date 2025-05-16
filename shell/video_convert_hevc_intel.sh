#!/bin/bash

input_dir="$(pwd)"
output_dir="${input_dir}/hevc"
mkdir -p "$output_dir"

# Create a list of files that are already in HEVC format
hevc_list="${input_dir}/hevc_list.txt"
[ -f "$hevc_list" ] && rm "$hevc_list"

for file in "${input_dir}"/*.mkv; do
    if ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 "$file" | grep -q "hevc"; then
        echo "$(basename "$file")" >> "$hevc_list"
    fi
done

# Convert files that are not in HEVC format
for file in "${input_dir}"/*.mkv; do
    if ! grep -q "$(basename "$file")" "$hevc_list"; then
        echo "Converting: $(basename "$file")"
        ffmpeg -hwaccel qsv -c:v h264_qsv -i "$file" -c:v hevc_qsv -global_quality 28 -map 0 -c:a copy -c:s copy "${output_dir}/$(basename "${file%.*}").mkv"
        if [ $? -ne 0 ]; then
            echo "Failed to convert: $(basename "$file")"
        fi
    else
        echo "Skipping: $(basename "$file") already HEVC"
    fi
done

echo "Conversion complete!"
