#!/bin/bash

set -e

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd /home/frappe/frappe-bench
    bench start
    exit 0
else
    echo "Creating new bench..."
fi

export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

cd /home/frappe

bench init --skip-redis-config-generation frappe-bench

cd /home/frappe/frappe-bench

# DB va Redis sozlash
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

# Procfile tozalash
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

# Apps
bench get-app payments
bench get-app lms

# Site yaratish
bench new-site lms.localhost \
--force \
--mariadb-root-password 123 \
--admin-password admin \
--no-mariadb-socket

# Install apps
bench --site lms.localhost install-app payments
bench --site lms.localhost install-app lms

# Dev mode
bench --site lms.localhost set-config developer_mode 1
bench --site lms.localhost clear-cache
bench use lms.localhost

bench start