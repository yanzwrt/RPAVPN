#!/bin/bash
# =========================================
# UPDATE SCRIPT MANAGER RAKHA-VPN
# Safe Auto Update System
# =========================================

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/yanzwrt/RPAVPN/main"
BIN_DIR="/usr/local/sbin"

# Semua file penting
files=(
  menu.sh
  menu-ws.sh
  menu-vless.sh
  menu-tr.sh
  menu-xrt.sh
  menu-xtr.sh
  menu-ssh.sh
  menu-l2tp.sh

  add-ws.sh
  add-vless.sh
  add-tr.sh
  add-xrt.sh
  add-xtr.sh
  add-ssh.sh
  add-l2tp.sh

  del-ws.sh
  del-vless.sh
  del-tr.sh
  del-xrt.sh
  del-xtr.sh
  del-ssh.sh
  del-l2tp.sh

  renew-ws.sh
  renew-vless.sh
  renew-tr.sh
  renew-xrt.sh
  renew-xtr.sh
  renew-ssh.sh
  renew-l2tp.sh

  cek-ws.sh
  cek-vless.sh
  cek-tr.sh
  cek-xrt.sh
  cek-xtr.sh
  cek-ssh.sh
  cek-l2tp.sh

  setup.sh
  setup2.sh
  ssh-vpn.sh
  ssh-vpn2.sh
  l2tp.sh
  xray.sh
  xray2.sh
  limit-speed.sh
  logcleaner.sh
  restart.sh
  status.sh
)

clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "      🔄 UPDATE SCRIPT RAKHA-VPN SYSTEM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📥 Mengunduh pembaruan dari repository:"
echo "➡ $REPO_URL"
echo ""

for file in "${files[@]}"; do
  echo "🔧 Memperbarui: $file"

  # Download aman, tidak fatal jika file tidak ada
  if curl -fsSL "$REPO_URL/$file" -o "$BIN_DIR/$file"; then
    chmod +x "$BIN_DIR/$file"
    echo "✔ $file berhasil diperbarui"
  else
    echo "⚠ $file dilewati (tidak ditemukan di repository)"
  fi

...
done

# Pastikan perintah "menu" memakai versi terbaru
if [ -f "$BIN_DIR/menu.sh" ]; then
  cp "$BIN_DIR/menu.sh" /usr/bin/menu
  chmod +x /usr/bin/menu
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   🔁 Restart service penting setelah update"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

systemctl restart xray 2>/dev/null || true
systemctl restart nginx 2>/dev/null || true
systemctl restart cron 2>/dev/null || true

echo ""
echo "✅ Pembaruan selesai!"
echo "ℹ Jalankan 'menu' untuk menggunakan script terbaru."
echo ""
