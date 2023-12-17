#!/bin/bash

# Function to create a table
create_table() {
    local dbname=$1
    local tablename=$2
    local num_columns=$3

    # Create table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table already exists
    if [ -e "$table_file" ]; then
        echo "Error: Table '$tablename' already exists in the database '$dbname'."
        exit 1
    fi

    # Create default ID column
    echo "ID" > "$table_file"

    # Prompt user to enter the names of columns
    for ((i = 1; i <= num_columns; i++)); do
        read -p "Enter the name of column $i: " column_name
        echo "$column_name" >> "$table_file"
    done

    echo "Table '$tablename' created successfully in the database '$dbname'."
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
display_databases

# Prompt the user to enter the name of the Database to create tables in
read -p "Enter the name of the Database to create tables in: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Check if the user is the owner or an admin
if [ "$(stat -c %U "Databases/$dbname")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
    echo "Error: You don't have permission to create tables in this database. Only admins or the owner can create tables."
    exit 1
fi

# Prompt the user to enter the name of the table, the number of columns, and the names of columns
read -p "Enter the name of the table: " tablename
read -p "Enter the number of columns: " num_columns

# Create the table
create_table "$dbname" "$tablename" "$num_columns"
