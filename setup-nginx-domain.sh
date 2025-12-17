#!/bin/bash

# Check argument
if [ -z "$1" ]; then
  echo "Usage: $0 domain.name"
  exit 1
fi

DOMAIN=$1
CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
LINK_PATH="/etc/nginx/sites-enabled/$DOMAIN"

# Check if configuration file already exists
if [ -e "$CONF_PATH" ]; then
  echo "Error: configuration for $DOMAIN already exists: $CONF_PATH"
  exit 1
fi

# Input configuration
echo "Enter configuration for $DOMAIN (finish input with CTRL+D):"
cat > /tmp/${DOMAIN}

# Move configuration to sites-available
sudo mv /tmp/${DOMAIN} "$CONF_PATH"

# Create symlink in sites-enabled
if [ ! -e "$LINK_PATH" ]; then
  sudo ln -s "$CONF_PATH" "$LINK_PATH"
fi

# Test Nginx configuration
sudo nginx -t
if [ $? -ne 0 ]; then
  echo "Error in configuration. Please check file: $CONF_PATH"
  exit 1
fi

# Reload Nginx
sudo service nginx reload

# Install Certbot and plugins
echo "[INFO] Installing Certbot and plugins..."
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Optional: install DNS plugins if needed
# sudo apt install -y python3-certbot-dns-cloudflare python3-certbot-dns-route53

# Obtain SSL certificate
echo "[INFO] Requesting SSL certificate for $DOMAIN..."
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m admin@$DOMAIN

echo "[SUCCESS] Domain $DOMAIN is configured with SSL"
