#!/bin/bash
# =========================================
# Media Stream Unlocker Test
# Mod By RakhaVPN x RPAVPN
# Version : 2.0
# =========================================

# Warna
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

# Tambahan warna singkat
orange="\033[33m"
CYAN="\033[36m"
NC="\033[0m"

# User-Agent browser default
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Opsi tambahan curl (biarkan kosong jika tidak perlu)
useNIC=""
xForward=""
ssll=""

clear
echo -e "  \033[1;37m${Font_Purple}Media Stream Unlocker Test Mod By RakhaVPN${Font_Suffix}\033[0m"
echo -e "  \033[1;37mVersion : 2.0 \033[0m"
echo -e "  \033[1;37mTime    : $(date)\033[0m"

export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# -----------------------------------------
# Fungsi helper
# -----------------------------------------

InstallJQ() {
    if [ -e "/etc/redhat-release" ]; then
        echo -e "${Font_Green}Menginstal dependensi: epel-release${Font_Suffix}"
        yum install epel-release -y -q > /dev/null
        echo -e "${Font_Green}Menginstal dependensi: jq${Font_Suffix}"
        yum install jq -y -q > /dev/null
    elif [[ $(grep '^ID=' /etc/os-release) =~ ubuntu ]] || [[ $(grep '^ID=' /etc/os-release) =~ debian ]]; then
        echo -e "${Font_Green}Memperbarui daftar paket...${Font_Suffix}"
        apt-get update -y > /dev/null
        echo -e "${Font_Green}Menginstal dependensi: jq${Font_Suffix}"
        apt-get install jq -y > /dev/null
    else
        echo -e "${Font_Red}Silakan instal jq secara manual.${Font_Suffix}"
        exit 1
    fi
}

InstallCurl() {
    if [ -e "/etc/redhat-release" ]; then
        echo -e "${Font_Green}Menginstal dependensi: curl${Font_Suffix}"
        yum install curl -y > /dev/null
    elif [[ $(grep '^ID=' /etc/os-release) =~ ubuntu ]] || [[ $(grep '^ID=' /etc/os-release) =~ debian ]]; then
        echo -e "${Font_Green}Memperbarui daftar paket...${Font_Suffix}"
        apt-get update -y > /dev/null
        echo -e "${Font_Green}Menginstal dependensi: curl${Font_Suffix}"
        apt-get install curl -y > /dev/null
    else
        echo -e "${Font_Red}Silakan instal curl secara manual.${Font_Suffix}"
        exit 1
    fi
}

PharseJSON() {
    # Cara pakai: PharseJSON "JSON" "key"
    # Contoh: PharseJSON '{"Value":"123"}' "Value" -> 123
    echo -n "$1" | jq -r .$2
}

# -----------------------------------------
# Test Game & Streaming
# -----------------------------------------

GameTest_Steam() {
    echo -n -e " Steam\t\t\t\t\t->\c"
    local result
    result=$(curl --user-agent "${UA_Browser}" -"${1}" -fsSL --max-time 10 https://store.steampowered.com/app/761830 2>&1 | grep priceCurrency | cut -d '"' -f4)

    if [ -z "$result" ]; then
        echo -e "\r Steam\t\t\t\t\t: ${Font_Red}Failed (Network Connection)${Font_Suffix}"
    else
        echo -e "\r Steam\t\t\t\t\t: ${Font_Green}Yes (Currency: ${result})${Font_Suffix}"
    fi
}

MediaUnlockTest_Netflix() {
    echo -n -e " Netflix\t\t\t\t->\c"
    local result1
    result1=$(curl $useNIC $xForward -"${1}" --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81403959" 2>&1)

    if [[ "$result1" == "404" ]]; then
        echo -e "\r Netflix\t\t\t\t: ${Font_Yellow}Originals Only${Font_Suffix}"
        return
    elif [[ "$result1" == "403" ]]; then
        echo -e "\r Netflix\t\t\t\t: ${Font_Red}No${Font_Suffix}"
        return
    elif [[ "$result1" == "200" ]]; then
        local region
        region=$(curl $useNIC $xForward -"${1}" --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1 | tr 'a-z' 'A-Z')
        [[ -z "$region" ]] && region="US"
        echo -e "\r Netflix\t\t\t\t: ${Font_Green}Yes (Region: ${region})${Font_Suffix}"
        return
    elif [[ "$result1" == "000" ]]; then
        echo -e "\r Netflix\t\t\t\t: ${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    fi

    echo -e "\r Netflix\t\t\t\t: ${Font_Red}Failed${Font_Suffix}"
}

MediaUnlockTest_HotStar() {
    echo -n -e " HotStar\t\t\t\t->\c"
    local result
    result=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -"${1}" ${ssll} -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://api.hotstar.com/o/v1/page/1557?offset=0&size=20&tao=0&tas=20")

    if [ "$result" = "000" ]; then
        echo -e "\r HotStar\t\t\t\t: ${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    elif [ "$result" = "401" ]; then
        local region site_region
        region=$(curl $useNIC $xForward --user-agent "${UA_Browser}" -"${1}" ${ssll} -sI "https://www.hotstar.com" | grep 'geo=' | sed 's/.*geo=//' | cut -f1 -d",")
        site_region=$(curl $useNIC $xForward -"${1}" ${ssll} -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://www.hotstar.com" | sed 's@.*com/@@' | tr 'a-z' 'A-Z')
        if [ -n "$region" ] && [ "$region" = "$site_region" ]; then
            echo -e "\r HotStar\t\t\t\t: ${Font_Green}Yes (Region: $region)${Font_Suffix}"
            return
        else
            echo -e "\r HotStar\t\t\t\t: ${Font_Red}No${Font_Suffix}"
            return
        fi
    elif [ "$result" = "475" ]; then
        echo -e "\r HotStar\t\t\t\t: ${Font_Red}No${Font_Suffix}"
        return
    fi

    echo -e "\r HotStar\t\t\t\t: ${Font_Red}Failed${Font_Suffix}"
}

MediaUnlockTest_iQiyi() {
    echo -n -e " iQiyi Global\t\t\t\t->\c"
    local tmpresult
    tmpresult=$(curl -"${1}" -s -I "https://www.iq.com/" 2>&1)
    if [[ "$tmpresult" == curl* ]]; then
        echo -e "\r iQiyi Global\t\t\t\t: ${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    fi

    local result
    result=$(echo "${tmpresult}" | grep 'mod=' | awk '{print $2}' | cut -f2 -d'=' | cut -f1 -d';')
    if [ -n "$result" ]; then
        if [[ "$result" == "ntw" ]]; then
            echo -e "\r iQiyi Global\t\t\t\t: ${Font_Green}Yes (Region: TW)${Font_Suffix}"
        else
            result=$(echo "${result}" | tr 'a-z' 'A-Z')
            echo -e "\r iQiyi Global\t\t\t\t: ${Font_Green}Yes (Region: ${result})${Font_Suffix}"
        fi
    else
        echo -e "\r iQiyi Global\t\t\t\t: ${Font_Red}Failed${Font_Suffix}"
    fi
}

MediaUnlockTest_Viu_com() {
    echo -n -e " Viu.com\t\t\t\t->\c"
    local tmpresult
    tmpresult=$(curl -"${1}" -s -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://www.viu.com/" 2>&1)
    if [[ "$tmpresult" == curl* ]]; then
        echo -e "\r Viu.com\t\t\t\t: ${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    fi

    local result
    result=$(echo "${tmpresult}" | cut -f5 -d"/")
    if [ -n "${result}" ]; then
        if [[ "${result}" == "no-service" ]]; then
            echo -e "\r Viu.com\t\t\t\t: ${Font_Red}No${Font_Suffix}"
        else
            result=$(echo "${result}" | tr 'a-z' 'A-Z')
            echo -e "\r Viu.com\t\t\t\t: ${Font_Green}Yes (Region: ${result})${Font_Suffix}"
        fi
    else
        echo -e "\r Viu.com\t\t\t\t: ${Font_Red}Failed${Font_Suffix}"
    fi
}

MediaUnlockTest_YouTube() {
    echo -n -e " YouTube\t\t\t\t->\c"
    local tmpresult region
    tmpresult=$(curl -"${1}" -s -H "Accept-Language: en" "https://www.youtube.com/premium")
    region=$(curl --user-agent "${UA_Browser}" -"${1}" -sL "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4)
    [[ -z "$region" ]] && region="US"

    if [[ "$tmpresult" == curl* ]]; then
        echo -e "\r YouTube\t\t\t\t: ${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    fi

    local result
    result=$(echo "$tmpresult" | grep 'Premium tidak tersedia di negara Anda')
    if [ -n "$result" ]; then
        echo -e "\r YouTube\t\t\t\t: ${Font_Red}No Premium${Font_Suffix} (Region: ${region})"
        return
    fi

    result=$(echo "$tmpresult" | grep 'YouTube and YouTube Music ad-free')
    if [ -n "$result" ]; then
        echo -e "\r YouTube\t\t\t\t: ${Font_Green}Yes (Region: ${region})${Font_Suffix}"
    else
        echo -e "\r YouTube\t\t\t\t: ${Font_Red}Failed${Font_Suffix}"
    fi
}

IPInfo() {
    local result
    result=$(curl -fsSL http://ip-api.com/json/ 2>&1)

    echo -n -e " IP\t\t\t\t\t->\c"
    local ip
    ip=$(PharseJSON "${result}" "query")
    echo -e "\r IP\t\t\t\t\t: ${Font_Green}${ip}${Font_Suffix}"

    echo -n -e " Country\t\t\t\t->\c"
    local country
    country=$(PharseJSON "${result}" "country")
    echo -e "\r Country\t\t\t\t: ${Font_Green}${country}${Font_Suffix}"

    echo -n -e " Region\t\t\t\t\t->\c"
    local region
    region=$(PharseJSON "${result}" "regionName")
    echo -e "\r Region\t\t\t\t\t: ${Font_Green}${region}${Font_Suffix}"

    echo -n -e " City\t\t\t\t\t->\c"
    local city
    city=$(PharseJSON "${result}" "city")
    echo -e "\r City\t\t\t\t\t: ${Font_Green}${city}${Font_Suffix}"

    echo -n -e " ISP\t\t\t\t\t->\c"
    local isp
    isp=$(PharseJSON "${result}" "isp")
    echo -e "\r ISP\t\t\t\t\t: ${Font_Green}${isp}${Font_Suffix}"
}

MediaUnlockTest() {
    IPInfo "${1}"
    global "${1}"
}

global() {
    echo -e "\n \033[1;37m${Font_Purple}-- Global --${Font_Suffix}\033[0m"
    MediaUnlockTest_Netflix "${1}"
    MediaUnlockTest_HotStar "${1}"
    MediaUnlockTest_YouTube "${1}"
    MediaUnlockTest_iQiyi "${1}"
    MediaUnlockTest_Viu_com "${1}"
    GameTest_Steam "${1}"
}

startcheck() {
    local mode family
    mode=$1
    family=$2
    mode=$(echo "${mode}" | tr 'A-Z' 'a-z')

    if [[ -n "${mode}" ]]; then
        case "${mode}" in
            'global')
                IPInfo "${family}"
                global "${family}"
            ;;
            *)
                MediaUnlockTest "${family}"
            ;;
        esac
    else
        MediaUnlockTest "${family}"
    fi
}

# -----------------------------------------
# Cek dependensi
# -----------------------------------------

if ! curl -V > /dev/null 2>&1; then
    InstallCurl
fi

if ! jq -V > /dev/null 2>&1; then
    InstallJQ
fi

# -----------------------------------------
# Test IPv4
# -----------------------------------------

echo ""
echo -e " \033[1;37m${Font_Purple}-- IPV4 --${Font_Suffix}\033[0m"
check4=$(ping -4 1.1.1.1 -c 1 2>&1)
if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]]; then
    startcheck "${1}" "4"
else
    echo -e "${Font_SkyBlue}Host saat ini tidak mendukung IPV4, lewati...${Font_Suffix}"
fi

# -----------------------------------------
# Test IPv6
# -----------------------------------------

echo ""
echo -e " \033[1;37m${Font_Purple}-- IPV6 --${Font_Suffix}\033[0m"
check6=$(ping6 240c::6666 -c 1 2>&1)
if [[ "$check6" != *"unreachable"* ]] && [[ "$check6" != *"Unreachable"* ]]; then
    startcheck "${1}" "6"
else
    echo -e "${Font_SkyBlue}Host saat ini tidak mendukung IPV6, lewati...${Font_Suffix}"
fi

echo ""
echo -e "${Font_Green}Tes Selesai${Font_Suffix}"
echo ""
echo -e "Script Mod By RakhaVPN"
echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${Font_Green}Enter${NC}${CYAN} ]${NC} untuk kembali ke menu . . .") " _
menu
