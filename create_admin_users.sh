#!/bin/bash

# Check if the Admins file exists
if [ ! -f "Admins" ]; then
    echo "Error: Admins file not found."
    exit 1 
fi

# Check if the "admins" group exists; create it if not
if ! getent group admins &>/dev/null; then
    groupadd admins
    echo "Group 'admins' created."
fi

# Create users and add them to the admins group
while IFS= read -r username; do
    if [ -z "$username" ]; then
        continue # Skip empty lines in the Admins file
    fi

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping."
        continue
    fi

    # Create user
    useradd -m "$username"

    # Add user to the admins group
    usermod -aG admins "$username"

    #? echo "User '$username' created and added to the admins group."
done <Admins

echo "Admin group creation complete."
