#!/bin/bash

# Define the name of the text file
file="Admins.txt"

# Create the group 'admins' if it doesn't exist
if ! getent group admins >/dev/null 2>&1; then
    groupadd admins
fi

# Read the file line by line and create users
while IFS= read -r username; do
    # Remove leading and trailing spaces
    username=$(echo "$username" | xargs)

    # Check if the username is empty
    if [ -z "$username" ]; then
        echo "Skipping empty line."
        continue
    fi

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."
    else
        # Create the user
        useradd -m "$username"
        if [ $? -eq 0 ]; then
            echo "User '$username' created."
            # Add the user to the 'admins' group
            usermod -aG admins "$username"
            echo "User '$username' added to the 'admins' group."
        else
            echo "Error creating user '$username'."
        fi
    fi
done <"$file"
