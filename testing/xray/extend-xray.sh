NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
clear
ACCOUNTS_FILE="/usr/local/etc/xray/accounts.tsv"
NUMBER_OF_CLIENTS=$(awk -F '\t' 'NF >= 2 { count++ } END { print count + 0 }' "$ACCOUNTS_FILE" 2>/dev/null)
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}Extend All Xray Account${NC}              "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
allxray
fi
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}Extend All Xray Account${NC}              "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}User  Expired${NC}  "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
awk -F '\t' 'NF >= 2 { print $1, $2 }' "$ACCOUNTS_FILE" | column -t | sort | uniq
echo ""
echo -e "${YB}tap enter to go back${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "Input Username : " user
if [ -z "$user" ]; then
allxray
else
read -p "Expired (days): " masaaktif
exp=$(awk -F '\t' -v user="$user" '$1 == user { print $2; exit }' "$ACCOUNTS_FILE")
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
awk -F '\t' -v OFS='\t' -v user="$user" -v exp="$exp4" '$1 == user { $2 = exp } { print }' "$ACCOUNTS_FILE" > "${ACCOUNTS_FILE}.tmp"
mv "${ACCOUNTS_FILE}.tmp" "$ACCOUNTS_FILE"
systemctl restart xray
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "          ${WB}All Xray Account Success Extended${NC}         "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp4"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
clear
allxray
fi
