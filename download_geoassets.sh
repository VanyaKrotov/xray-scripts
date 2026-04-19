#!/bin/bash

# Настройки
REPO="runetfreedom/russia-v2ray-rules-dat"
DEST_DIR="/usr/local/share/xray"
TMP_DIR=$(mktemp -d)

# Проверка на запуск от root (нужно для перемещения файлов)
if [ "$EUID" -ne 0 ]; then 
  echo "Пожалуйста, запустите скрипт с sudo"
  exit 1
fi

echo "--- Поиск последней версии в GitHub... ---"
# Получаем прямые ссылки на файлы из последнего релиза
GEOIP_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep "browser_download_url" | grep "geoip.dat" | cut -d '"' -f 4)
GEOSITE_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep "browser_download_url" | grep "geosite.dat" | cut -d '"' -f 4)

if [ -z "$GEOIP_URL" ] || [ -z "$GEOSITE_URL" ]; then
    echo "Ошибка: Не удалось найти файлы в последнем релизе."
    exit 1
fi

echo "--- Скачивание файлов во временную директорию... ---"
curl -L -o "$TMP_DIR/geoip.dat" "$GEOIP_URL"
curl -L -o "$TMP_DIR/geosite.dat" "$GEOSITE_URL"

echo "--- Установка файлов в $DEST_DIR... ---"
mkdir -p "$DEST_DIR"
mv "$TMP_DIR/geoip.dat" "$DEST_DIR/"
mv "$TMP_DIR/geosite.dat" "$DEST_DIR/"

# Очистка
rm -rf "$TMP_DIR"

echo "--- Готово! Файлы обновлены. ---"
ls -lh "$DEST_DIR"