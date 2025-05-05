#!/bin/bash
set -e

echo "🔧 Starting Magento entrypoint script..."

# Ensure correct permissions
echo "🔐 Setting permissions for env.php (if exists)..."
if [ -f app/etc/env.php ]; then
    chmod o-rwx app/etc/env.php
    echo "✅ Permissions set for env.php"
fi

# Enable maintenance mode
php bin/magento maintenance:enable

# Upgrade the setup
php bin/magento setup:upgrade

# Clear generated code and cache
rm -rf generated/* var/cache/* var/page_cache/* var/view_preprocessed/*

# Run DI compile if needed
echo "⚙️ Running setup:di:compile..."
php -d memory_limit=2G bin/magento setup:di:compile || true

# Deploy static content (optional, uncomment if needed)
php bin/magento setup:static-content:deploy -f

# Disable maintenance mode if enabled
if [ -f var/.maintenance.flag ]; then
    echo "🛠️ Disabling maintenance mode..."
    php bin/magento maintenance:disable || true
fi

# Install cron
echo "⚙️ Running cron:install..."
php php bin/magento cron:install || true

# Start Apache in foreground
echo "🚀 Starting Apache..."
exec apache2-foreground
