#!/bin/bash

# Set input and output directories
INPUT_DIR="$1"
OUTPUT_DIR="$2"

# Check if directories are provided
if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <input-directory> <output-directory>"
    exit 1
fi

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory $INPUT_DIR does not exist."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through all GIF files in the input directory
for gif in "$INPUT_DIR"/*.gif; do
    if [ -f "$gif" ]; then
        # Extract the file name without extension
        filename=$(basename "$gif" .gif)

        # Set output file path
        output="$OUTPUT_DIR/$filename.mp4"

        # Run ffmpeg to convert GIF to MP4
        ffmpeg -stream_loop 5 -i "$gif" -vf "scale=1920:-1,fps=30" -t 10 "$output"

        echo "Converted: $gif to $output"
    fi
done
