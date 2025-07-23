#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : Rakha-VPN
# (C) Copyright 2025
# =========================================
P='\e[0;35m'
B='\033[0;36m'
N='\e[0m'
clear
echo -e "\e[36m╒════════════════════════════════════════════╕\033[0m"
echo -e " \E[0;47;30m     🛡️ XRAY TROJAN WS MENU 🛡️           \E[0m"
echo -e "\e[36m╘════════════════════════════════════════════╛\033[0m

 [\033[1;36m•1 \033[0m]  Tambah Akun XRAY Trojan WS
 [\033[1;36m•2 \033[0m]  Buat Akun Trial XRAY Trojan WS
 [\033[1;36m•3 \033[0m]  Cek Login Pengguna XRAY Trojan WS
 [\033[1;36m•4 \033[0m]  Hapus Akun XRAY Trojan WS
 [\033[1;36m•5 \033[0m]  Perpanjang Akun XRAY Trojan WS
 [\033[1;36m•6 \033[0m]  Cek Konfigurasi XRAY Trojan WS

 [\033[1;36m•0 \033[0m]  Kembali Ke Menu Utama"
echo""
echo -e " \033[1;37mTekan [ Ctrl+C atau x ] • Untuk-Keluar-Script\033[0m"
echo ""
read -p " Pilih menu : " opt
echo -e ""
case $opt in
1) clear ; add-tr ;;
2) clear ; trial-tr ;;
3) clear ; cek-tr ;;
4) clear ; del-tr ;;
5) clear ; renew-tr ;;
6) clear ; user-tr ;;
0) clear ; menu ;;
x) exit ;;
*) echo "Tombol Salah" ; sleep 1 ; menu-tr ;;
esac
