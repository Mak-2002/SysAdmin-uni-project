#!/bin/bash

# Log directory
log_dir="/opt/logs"

# Check if the user is the owner or an admin
if [ "$(stat -c %U "$log_dir")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to log events. Only admins or the owner can log events."
    exit 1
fi

# Validate the number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <event_type> <database_name> <user>"
    exit 1
fi

# Extract arguments
event_type="$1"
database_name="$2"
user="$3"

# Log event
log_entry="$event_type:$database_name $user:$(if id -nG "$user" | grep -qw "admins"; then echo "admin"; elif [ "$(stat -c %U "$log_dir")" == "$user" ]; then echo "owner"; else echo "other"; fi) $(date)"
echo "$log_entry" >> "$log_dir/events.log"

# Perform logs rotation based on date (keep the latest ten days)
find "$log_dir" -type f -name 'events.log*' -mtime +10 -exec rm -f {} \;

echo "Event logged successfully: $log_entry"
