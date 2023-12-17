#!/bin/bash

# Function to display available databases
display_databases() {
    echo "Available Databases:"
    for database in Databases/*; do
        if [ -d "$database" ]; then
            echo "- $(basename "$database")"
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

# Function to retrieve all table data
retrieve_all_data() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Display all table data
    echo "All data in Table '$tablename':"
    cat "$table_file"
}

# Function to retrieve data based on specific criteria
retrieve_data_by_criteria() {
    local dbname=$1
    local tablename=$2

    # Table file
    table_file="Databases/$dbname/$tablename.txt"

    # Check if the table exists
    if [ ! -e "$table_file" ]; then
        echo "Error: Table '$tablename' does not exist in the database '$dbname'."
        exit 1
    fi

    # Prompt user to enter the value to search for
    read -p "Enter the value to search for: " search_value

    # Retrieve data based on specific criteria
    echo "Data in Table '$tablename' where value is '$search_value':"
    grep -w "$search_value" "$table_file"
}

# Display available databases
display_databases

# Prompt the user to enter the name of the Database to retrieve data from
read -p "Enter the name of the Database to retrieve data from: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
    echo "Error: Database '$dbname' does not exist."
    exit 1
fi

# Display tables in the selected database
display_tables "$dbname"

# Prompt the user to enter the name of the table to retrieve data from
read -p "Enter the name of the table to retrieve data from: " tablename

# Provide options for retrieving all data or data based on specific criteria
read -p "Choose an option (1. Retrieve all data / 2. Retrieve data based on specific criteria): " retrieve_option

case $retrieve_option in
1)
    retrieve_all_data "$dbname" "$tablename"
    ;;
2)
    retrieve_data_by_criteria "$dbname" "$tablename"
    ;;
*)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac
