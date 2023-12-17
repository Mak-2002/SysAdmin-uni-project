#!/bin/bash

# Function to display tables in a database
display_tables() {
    local dbname=$1

    echo "Tables in Database '$dbname':"
    for table in Databases/"$dbname"/*.txt; do
        if [ -f "$table" ]; then
            echo "- $(basename "$table" .txt)"
        fi
    done
}

# Function to delete a table
delete_table() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Check if the user is the owner or an admin
    if [ "$(stat -c %U "$table_file")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
        echo "Error: You don't have permission to delete this table. Only admins or the owner can delete tables."
        exit 1
    fi

    # Confirm with the user before deleting the table
    read -p "Are you sure you want to delete the table '$tablename' from the database '$dbname'? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Operation canceled."
        exit 0
    fi

    # Delete the table
    rm -f "$table_file"

    echo "Table '$tablename' deleted successfully from the database '$dbname'."
}

# Display available databases
echo "Available Databases:"
for database in Databases/*; do
    if [ -d "$database" ]; then
        echo "- $(basename "$database")"
    fi
done

# Prompt the user to enter the name of the Database to delete tables from
read -p "Enter the name of the Database to delete tables from: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Check if the user is the owner or an admin
if [ "$(stat -c %U "Databases/$dbname")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to delete tables from this database. Only admins or the owner can delete tables."
    exit 1
fi

# Display tables in the selected database
display_tables "$dbname"

# Prompt the user to enter the name of the table to delete
read -p "Enter the name of the table to delete: " tablename

# Delete the table
delete_table "$dbname" "$tablename"
