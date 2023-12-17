# Use the latest Ubuntu image as the base image
FROM ubuntu:latest

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y bash tar gzip

# Set the working directory inside the container
WORKDIR /app

# Set permissions for /app
RUN chmod 777 /app

# Copy the contents of the current directory into the container at /app
COPY . /app

# Make scripts executable
RUN chmod +x \
    create_admin_users.sh \
    create_table.sh \
    create.sh \
    delete_data.sh \
    delete_table.sh \
    delete.sh \
    insert_data.sh \
    retrieve_data.sh \
    update_date.sh \
    empty.sh \
    backup.sh \
    restore.sh \
    log_event.sh \
    export_logs.sh

# Specify the default command to run when the container starts
CMD ["./create_admin_users.sh"]
