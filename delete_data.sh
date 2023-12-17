#!/bin/bash

# Function to display available databases if it's owned by this user or this user is an admin
display_databases() {
    echo "Available Databases:"
    for database in Databases/*; do
        if [ -d "$database" ]; then
          # Get the database name
          dbname=$(basename "$database")

          if [ "$(stat -c %U "Databases/$dbname")" == "$(whoami)" ] || id -nG "$(whoami)" | grep -qw "admins"; then
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

# Function to delete all table data
delete_all_data() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Delete all data in the table
    > "$table_file"

    echo "All data in Table '$tablename' deleted successfully."
}

# Function to delete data based on specific criteria
delete_data_by_criteria() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Prompt user to enter the value to delete data based on
    read -p "Enter the value to delete data based on: " delete_value

    # Delete data based on specific criteria
    sed -i "/$delete_value/d" "$table_file"

    echo "Data in Table '$tablename' deleted based on criteria successfully."
}

# Display available databases
display_databases

# Prompt the user to enter the name of the Database to delete data from
read -p "Enter the name of the Database to delete data from: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Check if the user is the owner or an admin
if [ "$(stat -c %U "Databases/$dbname")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
  echo "Error: You don't have permission to delete data from tables in this database. Only admins or the owner can delete data."
  exit 1
fi

# Display tables in the selected database
display_tables "$dbname"

# Prompt the user to enter the name of the table to delete data from
read -p "Enter the name of the table to delete data from: " tablename

# Provide options for deleting all data or data based on specific criteria
read -p "Choose an option (1. Delete all data / 2. Delete data based on specific criteria): " delete_option

case $delete_option in
    1)
        delete_all_data "$dbname" "$tablename"
        ;;
    2)
        delete_data_by_criteria "$dbname" "$tablename"
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac
