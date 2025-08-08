#!/bin/bash
set -euo pipefail

SERVICE_NAME="menu-test"
PROJECT_DIR="/root/menu_test"
ALIAS_FILE="/root/.bash_aliases"
CADDY_CONFIG="/etc/caddy/Caddyfile"
SITE_ADDRESS="https://45.134.14.119:5000"

# Проверка прав root
if [ "$(id -u)" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт от root"
  exit 1
fi

echo "🛑 Остановка и отключение сервисов..."
systemctl stop $SERVICE_NAME 2>/dev/null || true
systemctl disable $SERVICE_NAME 2>/dev/null || true
systemctl stop caddy 2>/dev/null || true
systemctl disable caddy 2>/dev/null || true

echo "🗑️ Удаление конфигурации Caddy..."
# Удаляем только наш блок из Caddyfile, сохраняя остальные настройки
if [ -f "$CADDY_CONFIG" ]; then
    sed -i "\|$SITE_ADDRESS|,/^}/d" "$CADDY_CONFIG"
    
    # Если файл стал пустым после удаления, удаляем его полностью
    if [ ! -s "$CADDY_CONFIG" ]; then
        rm -f "$CADDY_CONFIG"
    fi
fi

echo "🔧 Перезагрузка конфигурации Caddy..."
systemctl daemon-reload
systemctl reset-failed

echo "🧹 Удаление системных служб..."
rm -f /etc/systemd/system/$SERVICE_NAME.service

echo "🧹 Удаление алиасов..."
sed -i '/# Алиасы для управления сервисом '"$SERVICE_NAME"'/,/^$/d' "$ALIAS_FILE"

echo "🧹 Удаление проекта и виртуального окружения..."
rm -rf "$PROJECT_DIR"

echo "🔒 Закрытие портов (если больше не используются)..."
ufw delete allow 5000/tcp 2>/dev/null || true
ufw delete allow 80/tcp 2>/dev/null || true
ufw delete allow 443/tcp 2>/dev/null || true
ufw reload

echo "✅ Сервис $SERVICE_NAME и связанные компоненты полностью удалены!"
echo "Для применения изменений выполните:"
echo "  source $ALIAS_FILE"
echo "И перезапустите терминал для очистки алиасов"