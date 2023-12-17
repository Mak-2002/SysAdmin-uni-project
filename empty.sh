#!/bin/bash

# Display available databases
    echo "Available Databases:"
    for database in Databases/*; do
        if [ -d "$database" ]; then
            echo "- $(basename "$database")"
        fi
    done

# Prompt the user to enter the name of the Database to empty
read -p "Enter the name of the Database to empty: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Check if the user is the owner or an admin
if [ "$(stat -c %U "Databases/$dbname")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to empty this database. Only admins or the owner can empty a database."
    exit 1
fi

# Check if the database is not empty
if [ -z "$(ls -A "Databases/$dbname")" ]; then
    echo "Database '$dbname' is already empty."
    exit 0
fi

# Confirm with the user before emptying the database
read -p "Are you sure you want to empty the database '$dbname'? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Operation canceled."
    exit 0
fi

# Empty the database by removing all files inside it
rm -f "Databases/$dbname"/*

echo "Database '$dbname' emptied successfully."
