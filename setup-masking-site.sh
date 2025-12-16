#!/bin/bash

# Check arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 DOMAIN HTML_PATH"
  exit 1
fi

DOMAIN=$1
HTML_PATH=$2

# List of URLs for random download
URLS=(
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/3d-glow-animation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/3d-hover-aimation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/ghost-animation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/neon-animation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/shadow-animation.html"
)

# 1. Install nginx
echo "[INFO] Installing Nginx..."
sudo apt update && sudo apt install -y nginx

# 2. Ensure UFW is installed and configured
if ! command -v ufw >/dev/null 2>&1; then
  echo "[INFO] UFW is not installed. Installing..."
  sudo apt install -y ufw
fi

UFW_STATUS=$(sudo ufw status | grep -i "Status:" | awk '{print $2}')
if [ "$UFW_STATUS" != "active" ]; then
  echo "[INFO] Enabling UFW..."
  sudo ufw enable
fi

echo "[INFO] Allowing Nginx Full profile in UFW..."
sudo ufw allow 'Nginx Full'

# 3. Download random file
mkdir -p "$HTML_PATH"
RANDOM_URL=${URLS[$RANDOM % ${#URLS[@]}]}
echo "[INFO] Downloading file: $RANDOM_URL"
curl -s "$RANDOM_URL" -o "$HTML_PATH/index.html"

# 4. Add nginx configuration
CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
LINK_PATH="/etc/nginx/sites-enabled/$DOMAIN"

echo "[INFO] Creating Nginx config for $DOMAIN..."
sudo bash -c "cat > $CONF_PATH" <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    root $HTML_PATH;
    index index.html;
}
EOF

# Create symlink
if [ ! -e "$LINK_PATH" ]; then
  sudo ln -s "$CONF_PATH" "$LINK_PATH"
fi

# Test configuration
echo "[INFO] Testing Nginx configuration..."
sudo nginx -t
if [ $? -ne 0 ]; then
  echo "[ERROR] Invalid Nginx configuration. Please check: $CONF_PATH"
  exit 1
fi

# 5. Reload nginx
echo "[INFO] Reloading Nginx..."
sudo systemctl reload nginx

echo "[SUCCESS] Domain $DOMAIN is configured and serving $HTML_PATH/index.html"
