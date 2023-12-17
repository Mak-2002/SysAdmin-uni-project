#!/bin/bash

# Restore directory
restore_dir="/opt/backups"

# Check if the user is the owner or an admin
if [ "$(stat -c %U "$restore_dir")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to perform restores. Only admins or the owner can perform restores."
    exit 1
fi

# List available backups
echo "Available Backups:"
ls "$restore_dir"

# Prompt user for the backup file to restore
read -p "Enter the name of the backup file to restore: " backup_file

# Restore the selected backup
tar xzf "$restore_dir/$backup_file" -C /path/to/restore/location

echo "Restore completed successfully."
