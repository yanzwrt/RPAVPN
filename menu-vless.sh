#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================
P='\e[0;35m'
B='\033[0;36m'
N='\e[0m'
clear
echo -e "\e[36m╒════════════════════════════════════════════╕\033[0m"
echo -e " \E[0;47;30m     📡 MENU XRAY VLESS WS 📡            \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m

 [\033[1;36m•1 \033[0m]  Tambah Akun XRAY Vless WS
 [\033[1;36m•2 \033[0m]  Buat Akun Trial XRAY Vless WS
 [\033[1;36m•3 \033[0m]  Cek Pengguna Login XRAY Vless WS
 [\033[1;36m•4 \033[0m]  Hapus Akun XRAY Vless WS
 [\033[1;36m•5 \033[0m]  Perpanjang Akun XRAY Vless WS
 [\033[1;36m•6 \033[0m]  Cek Konfigurasi XRAY Vless WS

 [\033[1;36m•0 \033[0m]  Kembali ke Menu Utama"
echo ""
echo -e " \033[1;37mTekan [ Ctrl+C ] • Untuk Keluar Dari Script\033[0m"
echo ""
read -p " Pilih Menu : " opt
echo -e ""
case $opt in
1) clear ; add-vless ;;
2) clear ; trial-vless ;;
3) clear ; cek-vless ;;
4) clear ; del-vless ;;
5) clear ; renew-vless ;;
6) clear ; user-vless ;;
0) clear ; menu ;;
x) exit ;;
*) echo "Pilihan Salah" ; sleep 1 ; menu-vless ;;
esac
