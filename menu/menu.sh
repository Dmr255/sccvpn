#!/bin/bash

# Warna untuk output (sesuaikan dengan kebutuhan)
NC='\e[0m'       # No Color (mengatur ulang warna teks ke default)
DEFBOLD='\e[39;1m' # Default Bold
RB='\e[31;1m'    # Red Bold
GB='\e[32;1m'    # Green Bold
YB='\e[33;1m'    # Yellow Bold
BB='\e[34;1m'    # Blue Bold
MB='\e[35;1m'    # Magenta Bold
CB='\e[36;1m'    # Cyan Bold
WB='\e[37;1m'    # White Bold

service_control() {
    local title=$1
    local cmd=$2

    clear
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "              ${WB}${title} Service Control${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}[1]${NC} ${YB}Start${NC}"
    echo -e " ${MB}[2]${NC} ${YB}Stop${NC}"
    echo -e " ${MB}[3]${NC} ${YB}Restart${NC}"
    echo -e " ${MB}[4]${NC} ${YB}Status${NC}"
    echo -e " ${MB}[5]${NC} ${YB}Enable on boot${NC}"
    echo -e " ${MB}[6]${NC} ${YB}Disable on boot${NC}"
    echo -e " ${MB}[7]${NC} ${YB}Show logs${NC}"
    echo -e " ${MB}[8]${NC} ${YB}Show config${NC}"
    echo -e " ${MB}[0]${NC} ${YB}Back To Menu${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    read -p "Select action: " act
    case $act in
        1) "$cmd" start ;;
        2) "$cmd" stop ;;
        3) "$cmd" restart ;;
        4) "$cmd" status ;;
        5) "$cmd" enable ;;
        6) "$cmd" disable ;;
        7) "$cmd" logs ;;
        8) "$cmd" config ;;
        0) show_menu ;;
        *) echo -e "${YB}Invalid selection${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to back on menu"
    show_menu
}

ssh_service() {
    service_control "SSH" ssh-ctl
}

sstp_service() {
    service_control "SSTP" sstp-ctl
}

zivpn_service() {
    service_control "ZIVPN" zivpn-ctl
}

# Fungsi untuk menampilkan menu
show_menu() {
    clear
    python /usr/bin/system_info.py
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "               ${WB}----- [ Xray Script ] -----${NC}              "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e "                   ${WB}----- [ Menu ] -----${NC}               "
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e " ${MB}[1]${NC} ${YB}Xray Menu${NC}"
    echo -e " ${MB}[2]${NC} ${YB}Xray Route${NC}"
    echo -e " ${MB}[3]${NC} ${YB}Xray Statistics${NC}"
    echo -e " ${MB}[4]${NC} ${YB}Log Create Account${NC}"
    echo -e " ${MB}[5]${NC} ${YB}Update Xray-core${NC}"
    echo -e " ${MB}[6]${NC} ${YB}Speedtest${NC}"
    echo -e " ${MB}[7]${NC} ${YB}Change Domain${NC}"
    echo -e " ${MB}[8]${NC} ${YB}Cert Acme.sh${NC}"
    echo -e " ${MB}[9]${NC} ${YB}About Script${NC}"
    echo -e " ${MB}[10]${NC} ${YB}SSH Service${NC}"
    echo -e " ${MB}[11]${NC} ${YB}SSTP Service${NC}"
    echo -e " ${MB}[12]${NC} ${YB}ZIVPN Service${NC}"
    echo -e "${BB}————————————————————————————————————————————————————————${NC}"
    echo -e ""
    # echo -e "${RB}Jika kalian mengubah domain maka Akun yang yang sudah dibuat akan hilang, Jadi tolong hati-hati.${NC}"
}

# Fungsi untuk menangani input menu
handle_menu() {
    read -p " Select Menu :  " opt
    echo -e ""
    case $opt in
        1) clear ; allxray ;;
        2) clear ; route-xray ;;
        3) clear ; python /usr/bin/traffic.py ; echo " " ; read -n 1 -s -r -p "Press any key to back on menu" ; show_menu ;;
        4) clear ; log-xray ;;
        5) clear ; update-xray ;;
        6) clear ; speedtest ; echo " " ; read -n 1 -s -r -p "Press any key to back on menu" ; show_menu ;;
        7) clear ; dns ;;
        8) clear ; certxray ;;
        9) clear ; about ;;
        10) ssh_service ;;
        11) sstp_service ;;
        12) zivpn_service ;;
        *) echo -e "${YB}Invalid input${NC}" ; sleep 1 ; show_menu ;;
    esac
}

# Tampilkan menu dan tangani input pengguna
while true; do
    show_menu
    handle_menu
done
