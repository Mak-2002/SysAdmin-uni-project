#!/bin/bash

# Prompt the user to enter the name of the Database
read -p "Database Name: " dbname

# Check if the database already exists
if [ -d "Databases/$dbname" ]; then
    echo "Error: Database already exists."
    exit 1
fi

# Create database directory
echo "Creating database directory..."
mkdir -p "Databases/$dbname"
echo "Database directory created successfully."

# Create a new group with the same name as the database (the owner group)
groupadd "$dbname"
# Add owner to the group
usermod -aG "$dbname" $(whoami)
# Set owner and group ownership of the database
chown $(whoami):"$dbname" "Databases/$dbname"
#? echo "Owner and group ownership set successfully."

# Determine if the database is public or private
echo "Choose the type of the Database:"
echo "1. Public"
echo "2. Private"
read -p "Choice(1/2): " dbtype

# TODO: create admin users when initializing the container
# TODO: modify database listing to only list the databases that user have access to

case $dbtype in
1)
    # Public Database
    # Grant full access to all users
    chmod 777 "Databases/$dbname"
    echo "Database set to public."
    ;;
2)
    # Private Database
    # Add users from the "admins" group to the private database group
    if getent group admins &>/dev/null; then
        users_in_admins=$(getent group admins | cut -d: -f4)
        for admin in $users_in_admins; do
            if id "$admin" &>/dev/null; then
                usermod -aG "$dbname" "$admin"
                # echo "User '$admin' added to the group."
            else
                echo "Warning: Admin user '$admin' not found."
            fi
        done
        echo "Users from 'admins' group added to the database group."
    else
        echo "Warning: Group 'admins' not found."
    fi
    echo "Database set to private."
    ;;
*)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo "Database $dbname created successfully."
