#!/bin/bash

DOMAIN=$1
ARCHIVE_PATH=$2

if [ -z "$DOMAIN" ]; then
    echo "Error: Specify domain. Example: ./setup_cert.sh example.com"
    exit 1
fi

if [ -z "$ARCHIVE_PATH" ]; then
    echo "Error: Specify domain. Example: ./setup_cert.sh example.com /path/to/archive.tar.gz"
    exit 1
fi

mkdir -p /var/lib/marzban/certs/$DOMAIN

# Unpack archive

tar -xzvf $ARCHIVE_PATH -C /var/lib/marzban/certs/$DOMAIN

ls /var/lib/marzban/certs/$DOMAIN

echo "Add to marzban cert file: /var/lib/marzban/certs/$DOMAIN/fullchain.pem"
echo "Add to marzban key file: /var/lib/marzban/certs/$DOMAIN/key.pem