#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN (Mod RPAVPN)
# (C) Hak Cipta 2025
# =========================================

P='\e[0;35m'
B='\033[0;36m'
N='\e[0m'

clear
echo -e "\e[36m╒════════════════════════════════════════════╕\033[0m"
echo -e " \E[0;47;30m         🧰 MENU XRAY TROJAN TCP 🧰       \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m"
echo ""
echo -e " [\033[1;36m•1 \033[0m]  Tambah Akun XRAY Trojan TCP"
echo -e " [\033[1;36m•2 \033[0m]  Buat Akun Trial XRAY Trojan TCP"
echo -e " [\033[1;36m•3 \033[0m]  Cek Pengguna Login XRAY Trojan TCP"
echo -e " [\033[1;36m•4 \033[0m]  Hapus Akun XRAY Trojan TCP"
echo -e " [\033[1;36m•5 \033[0m]  Perpanjang Akun XRAY Trojan TCP"
echo -e " [\033[1;36m•6 \033[0m]  Cek Konfigurasi XRAY Trojan TCP"
echo ""
echo -e " [\033[1;36m•0 \033[0m]  Kembali ke Menu Utama"
echo -e " [\033[1;36m•x \033[0m]  Keluar"
echo ""
echo -e " \033[1;37mTekan [ Ctrl+C ] • Untuk Keluar Dari Script\033[0m"
echo ""

read -p " Pilih Menu : " opt
echo ""

case "$opt" in
  1) clear ; add-xtr ;;
  2) clear ; trial-xtr ;;
  3) clear ; cek-xtr ;;
  4) clear ; del-xtr ;;
  5) clear ; renew-xtr ;;
  6) clear ; user-xtr ;;
  0) clear ; menu ;;
  x|X) exit ;;
  *)
     echo "Pilihan salah, silakan coba lagi..."
     sleep 1
     menu-xtr
     ;;
esac
