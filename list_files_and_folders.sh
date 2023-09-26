#!/bin/bash

# Function to calculate human-readable file size
human_readable_size() {
  local bytes=$1
  local sizes=("B" "KB" "MB" "GB" "TB" "PB")
  local i=0
  while ((bytes > 1024)); do
    bytes=$((bytes / 1024))
    ((i++))
  done
  echo "$bytes${sizes[$i]}"
}

# Function to format the date modified
format_date_modified() {
  local timestamp="$1"
  local formatted_date=$(date -d "@$timestamp" "+%b %d, %Y")
  echo "$formatted_date"
}

# Function to recursively list files and folders
list_files_and_folders() {
  local dir="$1"
  local indent="$2"

  for item in "$dir"/*; do
    local item_size=$(du -s "$item" 2>/dev/null | cut -f1)
    local date_modified=$(stat -c %Y "$item" 2>/dev/null)
    
    # Replace commas with hyphens in the path
    local renamed_path="${item//,/ - }"
    
    if [ -d "$item" ]; then
      echo "$renamed_path,Folder,$(human_readable_size "$item_size"),$(format_date_modified "$date_modified")"
      list_files_and_folders "$item" "  $indent"
    elif [ -f "$item" ]; then
      echo "$renamed_path,File,$(human_readable_size "$item_size"),$(format_date_modified "$date_modified")"
    fi
  done
}

# Check if a directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Check if the provided directory exists
if [ ! -d "$1" ]; then
  echo "Error: Directory '$1' does not exist."
  exit 1
fi

# Get the absolute path of the directory
directory=$(readlink -f "$1")

# Print the header
echo "Path,Type,Size,Date Modified"
echo "-------------------------------------------------------------"

# Call the function to list files and folders
list_files_and_folders "$directory" ""