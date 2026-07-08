#!/bin/bash
# Script untuk pull kode terbaru dan deploy ulang di Podman RHEL
set -e

echo "=== 1. Mengambil Kode Terbaru dari GitHub ==="
git pull origin main

echo "=== 2. Membuild Ulang Image Podman ==="
podman build -t katalog_web:latest .

echo "=== 3. Merestart Container ==="
if command -v podman-compose &> /dev/null; then
    echo "Menggunakan podman-compose..."
    podman-compose down
    podman-compose up -d
elif command -v docker-compose &> /dev/null; then
    echo "Menggunakan docker-compose..."
    docker-compose down
    docker-compose up -d
else
    echo "Warning: podman-compose atau docker-compose tidak ditemukan!"
    echo "Menjalankan container secara manual..."
    # Hapus container lama jika ada
    podman stop katalog_web || true
    podman rm katalog_web || true
    # Jalankan yang baru
    podman run -d \
      --name katalog_web \
      -p 8083:80 \
      --network global_net \
      -v .:/var/www/html:Z \
      --restart always \
      katalog_web:latest
fi

echo "=== Deployment Selesai! Web E-Katalog Sudah Terupdate ==="
