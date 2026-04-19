#!/bin/bash

# Настройки
REPO="runetfreedom/russia-v2ray-rules-dat"
DEST_DIR="/usr/local/share/xray"
TMP_DIR=$(mktemp -d)

# Проверка на root
if [ "$EUID" -ne 0 ]; then 
  echo "Ошибка: запустите скрипт через sudo (sudo ./update_xray_rules.sh)"
  exit 1
fi

echo "--- Подготовка... ---"
# Проверяем наличие curl
if ! command -v curl &> /dev/null; then
    apt-get update && apt-get install -y curl
fi

echo "--- Получение ссылок на файлы... ---"
# Получаем JSON последнего релиза и вытаскиваем ссылки через простую регулярку
RELEASE_JSON=$(curl -s https://api.github.com/repos/$REPO/releases/latest)

GEOIP_URL=$(echo "$RELEASE_JSON" | grep -oP '"browser_download_url":\s*"\K[^"]*geoip.dat' | head -1)
GEOSITE_URL=$(echo "$RELEASE_JSON" | grep -oP '"browser_download_url":\s*"\K[^"]*geosite.dat' | head -1)

# Проверка, не пустые ли переменные
if [ -z "$GEOIP_URL" ] || [ -z "$GEOSITE_URL" ]; then
    echo "Ошибка: Не удалось извлечь прямые ссылки. Проверьте интернет или лимиты GitHub API."
    exit 1
fi

echo "--- Скачивание файлов... ---"
# -f заставит curl выдать ошибку, если сервер вернет 404
curl -L -f -o "$TMP_DIR/geoip.dat" "$GEOIP_URL" || exit 1
curl -L -f -o "$TMP_DIR/geosite.dat" "$GEOSITE_URL" || exit 1

echo "--- Установка в $DEST_DIR... ---"
mkdir -p "$DEST_DIR"
mv -v "$TMP_DIR/geoip.dat" "$DEST_DIR/"
mv -v "$TMP_DIR/geosite.dat" "$DEST_DIR/"

# Очистка
rm -rf "$TMP_DIR"

echo "--- Готово! Проверка файлов: ---"
ls -lh "$DEST_DIR/geoip.dat" "$DEST_DIR/geosite.dat"