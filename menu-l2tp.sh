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
echo -e " \E[0;47;30m        🌐 MENU L2TP / IPSEC 🌐          \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m"
echo ""
echo -e " [\033[1;36m•1 \033[0m]  Tambah Akun L2TP"
echo -e " [\033[1;36m•2 \033[0m]  Buat Akun Trial L2TP"
echo -e " [\033[1;36m•3 \033[0m]  Cek Pengguna Login L2TP"
echo -e " [\033[1;36m•4 \033[0m]  Hapus Akun L2TP"
echo -e " [\033[1;36m•5 \033[0m]  Perpanjang Akun L2TP"
echo -e " [\033[1;36m•6 \033[0m]  Cek Konfigurasi L2TP/IPsec"
echo ""
echo -e " [\033[1;36m•0 \033[0m]  Kembali ke Menu Utama"
echo -e " [\033[1;36m•x \033[0m]  Keluar"
echo ""
echo -e " \033[1;37mTekan [ Ctrl+C ] • Untuk Keluar Dari Script\033[0m"
echo ""

read -p " Pilih Menu : " opt
echo ""

case "$opt" in
  1) clear ; add-l2tp ;;
  2) clear ; trial-l2tp ;;
  3) clear ; cek-l2tp ;;
  4) clear ; del-l2tp ;;
  5) clear ; renew-l2tp ;;
  6) clear ; user-l2tp ;;
  0) clear ; menu ;;
  x|X) exit ;;
  *)
     echo "Pilihan salah, silakan coba lagi..."
     sleep 1
     menu-l2tp
     ;;
esac
