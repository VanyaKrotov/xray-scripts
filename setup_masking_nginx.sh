#!/bin/bash

# Check arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 DOMAIN"
  exit 1
fi

DOMAIN=$1

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

# 3. Download random file
RANDOM_URL=${URLS[$RANDOM % ${#URLS[@]}]}
echo "[INFO] Downloading file: $RANDOM_URL"
sudo curl -L "$RANDOM_URL" -o "var/www/html/index.html"

# 4. Reload nginx
echo "[INFO] Reloading Nginx..."
sudo systemctl reload nginx

echo "[SUCCESS] Domain $DOMAIN is configured with SSL and serving $HTML_PATH/index.html"
