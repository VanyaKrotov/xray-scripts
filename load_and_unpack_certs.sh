#!/bin/bash

# 1. Get the domain name
read -p "Enter domain: " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "Error: Domain is empty."
    exit 1
fi

# Define the archive path based on the domain
ARCHIVE_NAME="marzban_cert_$DOMAIN.tar.gz"
ARCHIVE_PATH="/root/$ARCHIVE_NAME"

# 2. Get the node IP address
read -p "Enter node IP: " NODE_SERVER_IP

if [ -z "$NODE_SERVER_IP" ]; then
    echo "Error: IP address is empty."
    exit 1
fi

echo "Copying archive from $NODE_SERVER_IP..."

# 3. Copy the archive from the remote server to the current directory
scp "root@$NODE_SERVER_IP:$ARCHIVE_PATH" .

# Check if the scp command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy file from remote server."
    exit 1
fi

# 4. Create the target directory and unpack the archive
mkdir -p "/var/lib/marzban/certs/$DOMAIN"

echo "Unpacking archive..."
tar -xzvf "$ARCHIVE_NAME" -C "/var/lib/marzban/certs/$DOMAIN"

# Display the results
echo "--- Files in cert directory ---"
ls -l "/var/lib/marzban/certs/$DOMAIN"

echo "--------------------------------"
echo "Add to Marzban cert file: /var/lib/marzban/certs/$DOMAIN/fullchain.pem"
echo "Add to Marzban key file:  /var/lib/marzban/certs/$DOMAIN/key.pem"