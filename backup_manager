#!/bin/bash

# Config file location
CONFIG_FILE="$HOME/.config/scripts/backup_manager.config"
SCRIPT_NAME=$(basename "$0")

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found at $CONFIG_FILE"
    echo "Please create it with the following format:"
    echo "SOURCE_COLUMN                    REMOTE_COLUMN               REMOTE_PATH_COLUMN"
    echo "source1                          remote1                      remote_path1"
    echo "source2                          remote2                      remote_path2"
    exit 1
fi

# Read config file and populate backup options
declare -a backup_options
declare -A source_map
declare -A remote_map
declare -A path_map

index=1
while IFS= read -r line; do
    # Skip empty lines and header/comment lines
    [[ -z "$line" || "$line" =~ ^# || "$line" =~ ^SOURCE ]] && continue

    # Extract columns (assuming they're separated by whitespace)
    echo "$line"
    read -r source remote path <<< "$line"

    backup_options+=("$index) Backup $source to $remote:$path")
    source_map["$index"]="$source"
    remote_map["$index"]="$remote"
    path_map["$index"]="$path"
    ((index++))
done < "$CONFIG_FILE"

# Add "Backup all" option
backup_options+=("$index) Backup ALL")
backup_options+=("$((index+1))) Exit")

# Function to display menu
show_menu() {
    clear
    echo "===================================="
    echo "       Backup Manager"
    echo "===================================="
    for option in "${backup_options[@]}"; do
        echo "$option"
    done
    echo "===================================="
}

# Function to perform backup
perform_backup() {
    local choice=$1
    local source=${source_map["$choice"]}
    local remote=${remote_map["$choice"]}
    local path=${path_map["$choice"]}

    echo "Starting backup: $source to $remote:$path"
    echo "Running: rclone sync \"$source\" \"$remote:$path\""
    rclone sync "$source" "$remote:$path"
    echo "Backup completed: $source to $remote:$path"
}

# Main menu loop
while true; do
    show_menu
    read -p "Choose an option (1-$((index+1))): " choice

    # Validate input
    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a number."
        read -p "Press Enter to continue..."
        continue
    fi

    if (( choice == index )); then
        # Backup all
        echo "Starting ALL backups..."
        for i in "${!source_map[@]}"; do
            perform_backup "$i"
        done
        echo "All backups completed!"
        read -p "Press Enter to continue..."
    elif (( choice == index+1 )); then
        # Exit
        echo "Exiting..."
        exit 0
    elif (( choice >= 1 && choice < index )); then
        # Specific backup
        perform_backup "$choice"
        read -p "Press Enter to continue..."
    else
        echo "Invalid option. Please try again."
        read -p "Press Enter to continue..."
    fi
done
