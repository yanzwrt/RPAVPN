#!/bin/bash
# =========================================
# Secure Log Cleaner for RPAVPN
# Edition : Stable Edition V1.0
# Author  : RakhaVPN (mod RPAVPN)
# =========================================

clear

echo "Membersihkan log layanan yang aman..."

# Hanya log yang aman untuk dibersihkan
SAFE_LOGS=(
  /var/log/auth.log
  /var/log/kern.log
  /var/log/faillog
  /var/log/daemon.log
  /var/log/cron.log
  /var/log/xray/access.log
  /var/log/xray/error.log
  /var/log/dpkg.log
)

# truncate log dengan aman
for file in "${SAFE_LOGS[@]}"; do
  if [[ -f "$file" ]]; then
    echo "Membersihkan: $file"
    truncate -s 0 "$file"
  fi
done

# membersihkan semua log rotated tetapi aman
echo "Membersihkan file log .gz rotated..."
find /var/log -name "*.gz" -type f -delete

# memaksa logrotate bekerja sesuai aturan
logrotate -f /etc/logrotate.conf >/dev/null 2>&1

# restart layanan yang perlu
systemctl restart xray >/dev/null 2>&1 || true

clear
echo "=========================================="
echo "       Log berhasil dibersihkan!"
echo "       $(date)"
echo "=========================================="
