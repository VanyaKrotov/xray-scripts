#!/bin/bash

# Variables
DOMAIN=$1
EMAIL="example@gmail.com" # Replace with your email
CERT_DIR="/opt/marzban_certs/$DOMAIN"
ARCHIVE_NAME="marzban_cert_${DOMAIN}.tar.gz"

if [ -z "$DOMAIN" ]; then
    echo "Error: Specify domain. Example: ./setup_cert.sh example.com"
    exit 1
fi

# 1. Install dependencies and acme.sh
sudo apt update && sudo apt install -y socat tar
curl https://get.acme.sh | sh -s email=$EMAIL
source ~/.bashrc

# 2. Create directory for certificates
mkdir -p $CERT_DIR

# 3. Obtain certificate
# Stop Nginx if it is running to free port 80
if systemctl is-active --quiet nginx; then
    echo "Stopping Nginx..."
    sudo systemctl stop nginx
    NGINX_STOPPED=true
fi

~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --issue -d $DOMAIN --standalone

# 4. Copy files to working directory
~/.acme.sh/acme.sh --install-cert -d $DOMAIN \
    --key-file "$CERT_DIR/key.pem" \
    --fullchain-file "$CERT_DIR/fullchain.pem"

# Restart Nginx if it was stopped
if [ "$NGINX_STOPPED" = true ]; then
    echo "Starting Nginx..."
    sudo systemctl start nginx
fi

# 5. Pack into archive
tar -czvf $ARCHIVE_NAME -C $CERT_DIR .

echo "---------------------------------------------------"
echo "Done! Archive created: $(pwd)/$ARCHIVE_NAME"
echo "Files inside: key.pem and fullchain.pem"