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
display_databases

# Prompt the user to enter the name of the Database to delete
read -p "Enter the name of the Database to delete: " dbname

# Check if the database exists
if [ ! -d "Databases/$dbname" ]; then
  echo "Error: Database '$dbname' does not exist."
  exit 1
fi

# Check if the user is the owner or an admin
if [ "$(stat -c %U "Databases/$dbname")" != "$(whoami)" ] && ! id -nG "$(whoami)" | grep -qw "admins"; then
  echo "Error: You don't have permission to delete this database. Only admins or the owner can delete a database."
  exit 1
fi

# Check if the database is empty
if [ -n "$(ls -A "Databases/$dbname")" ]; then
  echo "Error: Database '$dbname' is not empty. Only empty databases can be deleted."
  exit 1
fi

# Delete the metadata of the Database
groupdel "$dbname"
rm -r "Databases/$dbname"

echo "Database '$dbname' deleted successfully."
