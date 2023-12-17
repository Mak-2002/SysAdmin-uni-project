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

# Function to insert data into a table
insert_data() {
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
        echo "Error: You don't have permission to insert data into this table. Only admins or the owner can insert data."
        exit 1
    fi

    # Display column names
    echo "Column names in Table '$tablename':"
    columns=($(head -n 1 "$table_file"))
    for column in "${columns[@]}"; do
        echo "- $column"
    done

    # Prompt user to enter data for each column
    read -p "Enter the data for each column (separated by spaces): " data_values

    # Append the data to the table file
    echo "$data_values" >>"$table_file"

    echo "Data inserted successfully into Table '$tablename' in the database '$dbname'."
}

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

# Display available databases
display_databases

# Prompt the user to enter the name of the Database to insert data into
read -p "Enter the name of the Database to insert data into: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Check if the user is the owner or an admin
if [ "$(stat -c %U "Databases/$dbname")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to insert data into tables in this database. Only admins or the owner can insert data."
    exit 1
fi

# Display tables in the selected database
display_tables "$dbname"

# Prompt the user to enter the name of the table to insert data into
read -p "Enter the name of the table to insert data into: " tablename

# Insert data into the selected table
insert_data "$dbname" "$tablename"
