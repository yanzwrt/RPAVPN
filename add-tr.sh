#!/bin/bash
# add-tr.sh - add trojan ws account (support SNI)
# Usage: place as /usr/bin/add-tr and make executable

domain=$(cat /root/domain 2>/dev/null || read -rp "Domain not set in /root/domain, enter domain: " domain && echo "$domain")
MYIP=$(curl -sS ifconfig.me || echo "127.0.0.1")

echo "================ Add Trojan WS (SNI) ================"
# username/password (alphanumeric+underscore)
until [[ $user =~ ^[a-zA-Z0-9_]+$ ]]; do
  read -rp "Username (also used as password): " user
done
read -rp "Bug Address (example: www.google.com) [default: $domain]: " address
read -rp "SNI / Host (example: m.facebook.com) [default: $domain]: " sni
read -rp "Masa aktif (hari): " masaaktif

# defaults
[[ -z $address ]] && address="$domain"
[[ -z $sni ]] && sni="$domain"
[[ -z $masaaktif ]] && masaaktif=30

exp=$(date -d "+${masaaktif} days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

# prepare password
password="$user"
bug_addr_trim="$address"
sts="${bug_addr_trim}."

# insert into trojanws.json (replace marker "###TR")
tfile="/usr/local/etc/xray/trojanws.json"
if [ -f "$tfile" ]; then
  # insert JSON object while keeping marker string "###TR"
  sed -i "0,/\\"###TR\\"/s//{\"password\":\"${user}\",\"email\":\"${user}\"},\\n    \"###TR\"/" "$tfile"
else
  echo "[WARN] $tfile not found"
fi

# insert into trnone.json (non-tls)
tnfile="/usr/local/etc/xray/trnone.json"
if [ -f "$tnfile" ]; then
  sed -i "0,/\\"###TRNONE\\"/s//{\"password\":\"${user}\",\"email\":\"${user}\"},\\n    \"###TRNONE\"/" "$tnfile"
else
  echo "[WARN] $tnfile not found"
fi

# reload services
systemctl restart xray@trojanws.service 2>/dev/null || systemctl restart xray.service 2>/dev/null
systemctl restart xray@trnone.service 2>/dev/null
systemctl restart nginx 2>/dev/null
service cron restart 2>/dev/null

# build links
trojanlink_tls="trojan://${user}@${sts}${domain}:443?type=ws&security=tls&host=${sni}&path=%2Ftrojan&sni=${sni}#XRAY_TROJAN_TLS_${user}"
trojanlink_ntls="trojan://${user}@${sts}${domain}:80?type=ws&security=none&host=${address}&path=%2Ftrojan#XRAY_TROJAN_NTLS_${user}"

# YAML preview (optional)
yaml_file="/home/vps/public_html/${user}-${exp}-TRTLS.yaml"
mkdir -p "$(dirname "${yaml_file}")"
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
proxies:
  - name: XRAY_TROJAN_TLS_${user}
    server: ${sts}${domain}
    port: 443
    type: trojan
    password: ${user}
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
cat <<EOF
========== Trojan WS Account Created ==========
Username/Password : ${user}
Domain            : ${domain}
Bug Address       : ${address}
SNI / Host        : ${sni}
Password          : ${user}
Port TLS          : 443
Port Non-TLS      : 80
Network           : ws
Path              : /trojan
Created           : ${hariini}
Expires           : ${exp}
Link TLS          : ${trojanlink_tls}
Link Non-TLS      : ${trojanlink_ntls}
YAML (preview)    : http://${MYIP}:81/${user}-${exp}-TRTLS.yaml
==============================================
EOF

read -n1 -r -p "Press any key to continue..." key
