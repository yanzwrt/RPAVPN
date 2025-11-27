#!/bin/bash
# =========================================
# RPAVPN | Hapus Akun SSH
# Edition : Stable Edition V1.0
# Author  : yanzwrt (base RakhaVPN)
# =========================================

clear
red='\e[1;31m'
green='\e[0;32m'
orange='\e[1;33m'
CYAN='\e[0;36m'
NC='\e[0m'

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m        Hapus Akun SSH Premium        \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Ambil user SSH VPN (dibuat oleh add-ssh: /bin/false, UID >= 1000)
mapfile -t USERS < <(awk -F: '$3>=1000 && $7=="/bin/false" {print $1}' /etc/passwd)

if [[ ${#USERS[@]} -eq 0 ]]; then
    echo "Tidak ada akun SSH premium (user /bin/false) yang terdaftar."
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
    menu
fi

echo " Pilih akun yang ingin dihapus:"
echo " Tekan CTRL+C untuk membatalkan."
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
printf " No  Expired         User\n"

i=0
for u in "${USERS[@]}"; do
    ((i++))
    exp_raw=$(chage -l "$u" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
    [[ "$exp_raw" == "never" || -z "$exp_raw" ]] && exp_raw="never"
    printf " %2s) %-14s %s\n" "$i" "$exp_raw" "$u"
done

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

NUMBER_OF_CLIENTS=${#USERS[@]}
CLIENT_NUMBER=0

until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    if [[ ${CLIENT_NUMBER} == '1' ]]; then
        read -rp "Pilih satu pengguna [1]: " CLIENT_NUMBER
    else
        read -rp "Pilih satu pengguna [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    fi
done

user=${USERS[$((CLIENT_NUMBER-1))]}
exp_raw=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
[[ "$exp_raw" == "never" || -z "$exp_raw" ]] && exp_raw="never"

# Hapus user SSH
userdel "$user" &>/dev/null

clear
echo " Akun SSH Premium Berhasil Dihapus"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Nama Pengguna : $user"
echo " Expired Pada  : $exp_raw"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo "Script Mod By RPAVPN"
echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu
