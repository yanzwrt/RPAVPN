#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : RakhaVPN (Mod)
# (C) Copyright 2025
# =========================================
clear

now=$(date +"%Y-%m-%d")

#===========================
# Auto Remove VMESS (WS)
#===========================
if [ -f /usr/local/etc/xray/config.json ]; then
  data=( $(grep '^### ' /usr/local/etc/xray/config.json | cut -d ' ' -f 2 | sort | uniq) )
  for user in "${data[@]}"; do
    exp=$(grep -w "^### $user" "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    [ -z "$exp" ] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/config.json
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/none.json 2>/dev/null
      rm -f /usr/local/etc/xray/$user-tls.json \
            /usr/local/etc/xray/$user-none.json \
            /usr/local/etc/xray/$user-maxis.json \
            /usr/local/etc/xray/$user-maxistv.json \
            /usr/local/etc/xray/$user-celcom.json \
            /usr/local/etc/xray/$user-digi.json \
            /usr/local/etc/xray/$user-yes.json \
            /usr/local/etc/xray/$user-umo.json
      rm -f /home/vps/public_html/$user-VMESSTLS.yaml \
            /home/vps/public_html/$user-VMESSNTLS.yaml
    fi
  done
  systemctl restart xray.service 2>/dev/null
  systemctl restart xray@none.service 2>/dev/null
fi

#===========================
# Auto Remove VLESS (WS)
#===========================
if [ -f /usr/local/etc/xray/vless.json ]; then
  data=( $(grep '^### ' /usr/local/etc/xray/vless.json | cut -d ' ' -f 2 | sort | uniq) )
  for user in "${data[@]}"; do
    exp=$(grep -w "^### $user" "/usr/local/etc/xray/vless.json" | cut -d ' ' -f 3 | sort | uniq)
    [ -z "$exp" ] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/vless.json
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/vnone.json 2>/dev/null
      rm -f /home/vps/public_html/$user-VLESSTLS.yaml \
            /home/vps/public_html/$user-VLESSNTLS.yaml
    fi
  done
  systemctl restart xray@vless.service 2>/dev/null
  systemctl restart xray@vnone.service 2>/dev/null
fi

#===========================
# Auto Remove TROJAN WS
#===========================
if [ -f /usr/local/etc/xray/trojanws.json ]; then
  data=( $(grep '^### ' /usr/local/etc/xray/trojanws.json | cut -d ' ' -f 2 | sort | uniq) )
  for user in "${data[@]}"; do
    exp=$(grep -w "^### $user" "/usr/local/etc/xray/trojanws.json" | cut -d ' ' -f 3 | sort | uniq)
    [ -z "$exp" ] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/trojanws.json
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/trnone.json 2>/dev/null

      # Nama YAML disesuaikan dengan user-tr.sh: ${user}-TRTLS.yaml
      rm -f /home/vps/public_html/$user-TRTLS.yaml

    fi
  done
  systemctl restart xray@trojanws.service 2>/dev/null
  systemctl restart xray@trnone.service 2>/dev/null
fi

#===========================
# Auto Remove TROJAN TCP
#===========================
if [ -f /usr/local/etc/xray/trojan.json ]; then
  data=( $(grep '^### ' /usr/local/etc/xray/trojan.json | cut -d ' ' -f 2 | sort | uniq) )
  for user in "${data[@]}"; do
    exp=$(grep -w "^### $user" "/usr/local/etc/xray/trojan.json" | cut -d ' ' -f 3 | sort | uniq)
    [ -z "$exp" ] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/trojan.json
      rm -f /home/vps/public_html/$user-TRTCP.yaml
    fi
  done
  systemctl restart xray@trojan.service 2>/dev/null
fi

#===========================
# Auto Remove TROJAN TCP XTLS
#===========================
if [ -f /usr/local/etc/xray/xtrojan.json ]; then
  data=( $(grep '^### ' /usr/local/etc/xray/xtrojan.json | cut -d ' ' -f 2 | sort | uniq) )
  for user in "${data[@]}"; do
    exp=$(grep -w "^### $user" "/usr/local/etc/xray/xtrojan.json" | cut -d ' ' -f 3 | sort | uniq)
    [ -z "$exp" ] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
      sed -i "/^### $user $exp/,/^},{/d" /usr/local/etc/xray/xtrojan.json
      rm -f /home/vps/public_html/$user-TRDIRECT.yaml \
            /home/vps/public_html/$user-TRSPLICE.yaml
    fi
  done
  systemctl restart xray@xtrojan.service 2>/dev/null
fi
