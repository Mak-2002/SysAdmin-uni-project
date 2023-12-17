#!/bin/bash

# Function to display available databases for users in the private database group
display_databases() {
    echo "Available Databases:"
    for database in Databases/*; do
        if [ -d "$database" ]; then
            # Get the database name
            dbname=$(basename "$database")

            # Check if the user is a member of the private database group
            if id -nG "$(whoami)" | grep -qw "$dbname"; then
                echo "- $dbname"
            fi
        fi
    done
}

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

# Function to display columns in a table
display_columns() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Display columns in the selected table
    echo "Columns in Table '$tablename':"
    columns=($(head -n 1 "$table_file"))
    for column in "${columns[@]}"; do
        echo "- $column"
    done
}

# Function to update data in a table
update_data() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Display columns in the selected table
    display_columns "$dbname" "$tablename"

    # Prompt user to choose a column to update
    read -p "Choose a column to update: " update_column

    # Check if the chosen column exists
    if ! grep -qw "$update_column" <(head -n 1 "$table_file"); then
        echo "Error: Column '$update_column' does not exist in the table '$tablename'."
        exit 1
    fi

    # Prompt user to specify the ID of the row to update
    read -p "Enter the ID of the row to update: " update_id

    # Check if the specified ID exists in the table
    if ! grep -qw "^$update_id" "$table_file"; then
        echo "Error: ID '$update_id' does not exist in the table '$tablename'."
        exit 1
    fi

    # Prompt user to enter the new value for the chosen column
    read -p "Enter the new value for '$update_column': " new_value

    # Update the specified row with the new value
    sed -i "/^$update_id/ s/\($update_column \)[^ ]*/\1$new_value/" "$table_file"

    echo "Data in Table '$tablename' updated successfully."
}

# Display available databases
display_databases

# Prompt the user to enter the name of the Database to update data in
read -p "Enter the name of the Database to update data in: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Check if the user is a member of the private database group or the database is public 
# (the user has access to the database)
if ! [ -w "$database" ] ; then
    echo "Error:  You don't have permission to update data in tables in this database. Only users from the same private group can update data."
    exit 1
fi

# Display tables in the selected database
display_tables "$dbname"

# Prompt the user to enter the name of the table to update data in
read -p "Enter the name of the table to update data in: " tablename

# Update data in the specified table
update_data "$dbname" "$tablename"
