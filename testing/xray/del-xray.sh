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
CONFIG_FILE="/usr/local/etc/xray/config/04_inbounds.json"
ACCOUNTS_FILE="/usr/local/etc/xray/accounts.tsv"
NUMBER_OF_CLIENTS=$(awk -F '\t' 'NF >= 2 { count++ } END { print count + 0 }' "$ACCOUNTS_FILE" 2>/dev/null)
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "              ${WB}Delete All Xray Account${NC}               "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}You have no existing clients!${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
allxray
fi
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "              ${WB}Delete All Xray Account${NC}               "
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
exp=$(awk -F '\t' -v user="$user" '$1 == user { print $2; exit }' "$ACCOUNTS_FILE")
tmp_file=$(mktemp)
jq --arg user "$user" '.inbounds |= map(if (.settings.clients? | type) == "array" then .settings.clients |= map(select(.email != $user)) else . end)' "$CONFIG_FILE" > "$tmp_file" && mv "$tmp_file" "$CONFIG_FILE"
grep -v -F "${user}	" "$ACCOUNTS_FILE" > "${ACCOUNTS_FILE}.tmp" || true
mv "${ACCOUNTS_FILE}.tmp" "$ACCOUNTS_FILE"
rm -rf /var/www/html/xray/xray-$user.html
rm -rf /user/xray-$user.log
systemctl restart xray
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "          ${WB}All Xray Account Success Deleted${NC}          "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e " ${YB}Client Name :${NC} $user"
echo -e " ${YB}Expired On  :${NC} $exp"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
clear
allxray
fi
