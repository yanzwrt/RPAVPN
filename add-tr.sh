#!/bin/bash
# add-tr.sh - add trojan ws account (support SNI)
# Usage: place as /usr/bin/add-tr and make executable

clear
# warna
NC='\e[0m'; RB='\e[31;1m'; GB='\e[32;1m'; YB='\e[33;1m'; BB='\e[34;1m'; WB='\e[37;1m'

domain=$(cat /root/domain 2>/dev/null)
MYIP=$(curl -sS ifconfig.me)

echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}      🛡️ Tambah Akun XRAY TROJAN WS (SNI) 🛡️    ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"

# read user
until [[ $user =~ ^[a-zA-Z0-9_]+$ ]]; do
  read -rp "➤ Masukkan Nama Pengguna/Password : " -e user
done

# read bug address & sni
read -rp "➤ Bug Address (cth: www.google.com) : " address
read -rp "➤ Bug SNI/Host (cth: m.facebook.com) : " hst
read -rp "➤ Masa Aktif (hari) : " masaaktif

# fallback defaults
[[ -z $address ]] && address="${domain}"
[[ -z $hst ]] && hst="${domain}"

# prepare values
bug_addr="${address}"          # bug address, biasanya domain tujuan + dot rules
bug_addr_trim="${bug_addr}"
sni="${hst}"                   # sni/host untuk TLS handshake / query param
exp=$(date -d "+${masaaktif} days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

# password gunakan username (atau buat random jika mau)
password="${user}"

# insert into trojan config files
# expects marker lines in /usr/local/etc/xray/trojanws.json like:  #tr
# and in /usr/local/etc/xray/trnone.json like:  #trnone

if [ -f /usr/local/etc/xray/trojanws.json ]; then
  sed -i '/#tr$/a\### '"$user $exp"'\n},{"password": "'$password'","email": "'$user'"' /usr/local/etc/xray/trojanws.json
else
  echo "[WARN] /usr/local/etc/xray/trojanws.json not found, skipping TLS insertion"
fi

if [ -f /usr/local/etc/xray/trnone.json ]; then
  sed -i '/#trnone$/a\### '"$user $exp"'\n},{"password": "'$password'","email": "'$user'"' /usr/local/etc/xray/trnone.json
else
  echo "[WARN] /usr/local/etc/xray/trnone.json not found, skipping non-TLS insertion"
fi

# restart services
systemctl restart xray@trojanws.service 2>/dev/null
systemctl restart xray@trnone.service 2>/dev/null
systemctl restart nginx 2>/dev/null
service cron restart 2>/dev/null

# prepare links (include sni parameter for TLS link)
# sts used in original scripts: use address without trailing dot
sts="${bug_addr_trim}."

trojanlink_tls="trojan://${password}@${sts}${domain}:443?type=ws&security=tls&host=${domain}&path=%2Ftrojan&sni=${sni}#XRAY_TROJAN_TLS_${user}"
trojanlink_ntls="trojan://${password}@${sts}${domain}:80?type=ws&security=none&host=${domain}&path=%2Ftrojan#XRAY_TROJAN_NTLS_${user}"

# YAML preview
yaml_file="/home/vps/public_html/${user}-${exp}-TRTLS.yaml"
cat > "${yaml_file}" <<EOF
port: 7890
socks-port: 7891
redir-port: 7892
mixed-port: 7893
ipv6: false
mode: rule
log-level: silent
allow-lan: true
external-controller: 0.0.0.0:9090
profile:
  store-selected: true
dns:
  enable: true
  listen: 0.0.0.0:7874
  nameserver:
    - 8.8.8.8
proxies:
  - name: XRAY_TROJAN_TLS_${user}
    server: ${sts}${domain}
    port: 443
    type: trojan
    password: ${password}
    skip-cert-verify: true
    sni: ${sni}
    network: ws
    ws-opts:
      path: /trojan
      headers:
        Host: ${sni}
proxy-groups:
  - name: RakhaVPN-Autoscript
    type: select
    proxies:
      - XRAY_TROJAN_TLS_${user}
      - DIRECT
rules:
  - MATCH,RakhaVPN-Autoscript
EOF

# output
clear
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}            Detail Akun XRAY TROJAN WS          ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📌 Username         : ${user}"
echo -e "🌐 Domain           : ${domain}"
echo -e "📡 Bug Address      : ${address}"
echo -e "🔒 SNI / Host       : ${sni}"
echo -e "🔑 Password         : ${password}"
echo -e "🔒 Port TLS         : 443"
echo -e "🔓 Port Non-TLS     : 80"
echo -e "🔁 Network          : ws"
echo -e "📄 Path TLS-NTLS    : /trojan"
echo -e "📆 Tanggal Dibuat   : ${hariini}"
echo -e "⏳ Berakhir Pada    : ${exp}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link TLS         : ${trojanlink_tls}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link Non-TLS     : ${trojanlink_ntls}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📄 YAML TLS         : http://${MYIP}:81/${user}-${exp}-TRTLS.yaml"
echo -e "${BB}════════════════════════════════════════════════${NC}"
read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"
# end
