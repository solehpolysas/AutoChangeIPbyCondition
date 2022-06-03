#!/bin/bash
Area="SG"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36";
Font_Black="\033[30m";
Font_Red="\033[31m";
Font_Green="\033[32m";
Font_Yellow="\033[33m";
Font_Blue="\033[34m";
Font_Purple="\033[35m";
Font_SkyBlue="\033[36m";
Font_White="\033[37m";
Font_Suffix="\033[0m";

function MediaUnlockTest() {
    while true
    do
    cf_ip=$(dig +short myip.opendns.com @resolver1.opendns.com);
    echo -n -e " Netflix:\t\t${cf_ip}\t\t->\c";
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://www.netflix.com/" 2>&1`;
    if [ "$result" == "Not Available" ];then
        echo -n -e "\r Netflix:\t\t${cf_ip}\t\t${Font_Red}Unsupport${Font_Suffix}\n"
        systemctl restart wg-quick@wgcf
        sleep 5
        continue
    fi
    
    if [[ "$result" == "curl"* ]];then
        echo -n -e "\r Netflix:\t\t${cf_ip}\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        systemctl restart wg-quick@wgcf
        sleep 5
        continue
    fi
    cf_ip=$(dig +short myip.opendns.com @resolver1.opendns.com);
    local result=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80018499" 2>&1`;
    if [[ "$result" == *"page-404"* ]] || [[ "$result" == *"NSEZ-403"* ]];then
        echo -n -e "\r Netflix:\t\t${cf_ip}\t\t${Font_Red}No${Font_Suffix}\n"
        systemctl restart wg-quick@wgcf
        sleep 5
        continue
    fi
    cf_ip=$(dig +short myip.opendns.com @resolver1.opendns.com);
    local result1=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70143836" 2>&1`;
    local result2=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80027042" 2>&1`;
    local result3=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70140425" 2>&1`;
    local result4=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70283261" 2>&1`;
    local result5=`curl -${1} --user-agent "${UA_Browser}"-sL "https://www.netflix.com/title/70143860" 2>&1`;
    local result6=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70202589" 2>&1`;
    
    if [[ "$result1" == *"page-404"* ]] && [[ "$result2" == *"page-404"* ]] && [[ "$result3" == *"page-404"* ]] && [[ "$result4" == *"page-404"* ]] && [[ "$result5" == *"page-404"* ]] && [[ "$result6" == *"page-404"* ]];then
        echo -n -e "\r Netflix:\t\t${cf_ip}\t\t${Font_Yellow}[N] HomeMade Only${Font_Suffix}\n"
        systemctl restart wg-quick@wgcf
        sleep 5
        continue
    fi
    
    local region=`tr [:lower:] [:upper:] <<< $(curl -${1} --user-agent "${UA_Browser}" -fs --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
    
    if [[ ! -n "$region" ]];then
        region="US";
    fi
    echo -n -e "\r Netflix:\t\t${cf_ip}\t\t${Font_Green}Yes(Region: ${region})${Font_Suffix}\n"
    if [[ "$region" == "$Area" ]];then
        return
    fi
    done
    }

check4=`ping 1.1.1.1 -c 1 2>&1`;
check6=`ping6 240c::6666 -c 3 -w 3 2>&1`;
if [ "$(pgrep -f /root/cf.sh | wc -l)" -gt 2 ]; then
        echo "CF Already Running!"
        exit 1
else
        echo "NO Duplicate CF Running."
        if [[ "$check4" != *"unreachable"* ]] && [[ "$check4" != *"Unreachable"* ]];then
	    	echo -e " ${Font_SkyBlue}** Hunt IPV4 & Check Status${Font_Suffix} "
	    	MediaUnlockTest 4;
	elif [[ "$check6" != *"unreachable"* ]] && [[ "$check6" != *"Unreachable"* ]];then
		echo -e " ${Font_SkyBlue}** Hunt IPV6 & Check Status${Font_Suffix} "
		MediaUnlockTest 6;
fi
fi

