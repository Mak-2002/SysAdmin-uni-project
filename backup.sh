#!/bin/bash

# Backup directory
backup_dir="/opt/backups"

# Check if the user is the owner or an admin
if [ "$(stat -c %U "$backup_dir")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to perform backups. Only admins or the owner can perform backups."
    exit 1
fi

# Prompt user for backup options
echo "Backup Options:"
echo "1. Schedule backup (daily, weekly, or monthly)"
echo "2. Backup databases updated on a certain date"
read -p "Choose option (1/2): " backup_option

case $backup_option in
    1)
        # Schedule backup
        read -p "Enter schedule option (daily/weekly/monthly): " schedule_option
        backup_file="$backup_dir/backup_$(date +'%Y%m%d_%H%M%S').tar.gz"
        tar czf "$backup_file" -C /path/to/databases .
        ;;
    2)
        # Backup databases updated on a certain date
        read -p "Enter date (YYYYMMDD) to backup databases updated on that date: " backup_date
        backup_file="$backup_dir/backup_date_$backup_date.tar.gz"
        find /path/to/databases -newermt "$backup_date" -exec tar czf "$backup_file" -C {} +
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Perform database rotation based on backup date or size (choose one option)
# Option 1: Rotate based on backup date
find "$backup_dir" -type f -name 'backup*' -printf '%T@ %p\n' | sort -nr | awk 'NR>5 {print $2}' | xargs rm -f

# Option 2: Rotate based on backup size (adjust the threshold as needed)
max_backup_size_mb=500
while [ "$(du -s "$backup_dir" | cut -f1)" -gt "$((max_backup_size_mb * 1024))" ]; do
    find "$backup_dir" -type f -name 'backup*' -printf '%s %p\n' | sort -nr | awk 'NR>5 {print $2}' | xargs rm -f
done

echo "Backup completed successfully."
