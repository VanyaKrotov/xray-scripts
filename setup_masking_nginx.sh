#!/bin/bash

# List of URLs for random download
URLS=(
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/3d-glow-animation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/3d-hover-aimation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/ghost-animation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/neon-animation.html"
  "https://github.com/VanyaKrotov/css-animations/raw/refs/heads/main/animations/shadow-animation.html"
)

# 1. Check if nginx is installed
if dpkg -l | grep -q nginx; then
    echo "[INFO] Nginx is already installed. Skipping installation."
else
    echo "[INFO] Installing Nginx..."
    sudo apt update && sudo apt install -y nginx
fi

# 2. Download random file
RANDOM_URL=${URLS[$RANDOM % ${#URLS[@]}]}
echo "[INFO] Downloading file: $RANDOM_URL"
sudo curl -L "$RANDOM_URL" -o "/var/www/html/index.html"

# 3. Reload nginx
echo "[INFO] Reloading Nginx..."
sudo systemctl reload nginx

echo "[SUCCESS] Nginx is configured and serving the downloaded file."
