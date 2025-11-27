#!/bin/bash
# Update helper to pull the latest scripts from GitHub
set -euo pipefail
REPO_URL="https://raw.githubusercontent.com/yanzwrt/RPAVPN/main"
BIN_DIR="/usr/local/sbin"

files=(
  menu.sh
  setup.sh
  setup2.sh
  ssh-vpn.sh
  l2tp.sh
  xray.sh
)

echo "Mengunduh pembaruan dari $REPO_URL"
for file in "${files[@]}"; do
  target="$BIN_DIR/$(basename "$file")"
  echo "- Memperbarui $target"
  curl -fsSL "$REPO_URL/$file" -o "$target"
  chmod +x "$target"
done

echo "Pembaruan selesai. Jalankan ulang layanan jika diperlukan."
