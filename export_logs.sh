#!/bin/bash

# Log directory
log_dir="/opt/logs"

# Check if the user is the owner or an admin
if [ "$(stat -c %U "$log_dir")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to export logs. Only admins or the owner can export logs."
    exit 1
fi

# Export logs to Excel file
excel_file="$log_dir/logs_$(date +'%Y%m%d_%H%M%S').xlsx"
awk -F: '{ print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6 }' "$log_dir/events.log" > "$excel_file"

echo "Logs exported succesfully to: $excel_file"
