# Backup Manager Script

A bash script that provides an interactive menu for manually triggering `rclone` backups, complementing your existing cron jobs.

## Features

- 📂 Reads backup configurations from an external config file
- 🖥️ Interactive menu interface for easy manual backups
- ⚡ Run specific backups or all backups at once
- 🔄 Uses `rclone sync` just like your cron jobs
- ✅ Input validation and user-friendly feedback

## Configuration File Setup

Create a config file at: `~/.config/scripts/backup_manager.config`

### Format:
```
# SOURCE        REMOTE          REMOTE_PATH
[local path]    [remote name]   [remote path]
```

## How the Script Works

### 1. Initialization
- Sets config file location
- Checks if config file exists
- Initializes data structures for storing backup options

### 2. Config File Parsing
- Reads each line of the config file
- Skips empty lines and comments (lines starting with #)
- Stores sources, remotes, and paths in separate associative arrays
- Builds menu options dynamically

### 3. Interactive Menu
- Displays all backup options in numbered list
- Includes "Backup ALL" and "Exit" options
- Uses `read -r` for safe input handling

### 4. Backup Execution
- For single backups: runs `rclone sync` with the selected paths
- For "Backup ALL": runs all backups sequentially
- Provides clear feedback before and after each operation

## Key Technical Details

### The `read` Command
- `-p`: Displays a prompt
- `-r`: Raw input mode (preserves backslashes)
- Example: `read -r -p "Enter choice: " input`

### Data Structures Used
- Arrays (`declare -a`) for menu options
- Associative arrays (`declare -A`) for path mappings
- Arithmetic expansion (`$((index+1))`) for dynamic numbering

### Input Validation
- Checks if input is numeric
- Verifies input is within valid range
- Handles invalid input gracefully

## Why -r Matters in read
Always use -r with read to:
- Preserve backslashes in paths
- Handle special characters correctly
- Prevent unexpected interpretation of escape sequences

## Best Practices
- Keep your config file paths clean (no trailing spaces)
- Use absolute paths for reliability
- The script can be extended to:
  - Add backup verification
  - Include logging
  - Send notifications