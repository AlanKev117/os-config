#!/bin/bash

# Renames files in a folder with their SHA256 hash code plus time and random
# segments, keeping the extension

# Check if the folder is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

FOLDER="$1"

# Check if the folder exists
if [ ! -d "$FOLDER" ]; then
    echo "Error: $FOLDER is not a directory."
    exit 1
fi

# Process each file in the folder
for file in "$FOLDER"/*; do
    # Skip if it's not a regular file
    [ -f "$file" ] || continue

    # Extract the file name and extension
    filename=$(basename "$file")
    extension="${filename##*.}"
    base_name="${filename%.*}"

    # Handle files without extensions
    if [ "$base_name" == "$filename" ]; then
        extension=""
    else
        extension=".$extension"
    fi

    # Compute SHA256 hash of the file name (excluding the extension)
    hash=$(echo -n "$base_name" | sha256sum | awk '{print $1}')

    # Ensure unique new file names by appending a timestamp and random number
    timestamp=$(date +%s)
    random_number=$RANDOM
    new_name="$FOLDER/${hash}_${timestamp}_${random_number}${extension}"

    # Rename the file
    mv "$file" "$new_name"
    echo "Renamed: $filename -> $(basename "$new_name")"
done

echo "Renaming completed."