#!/bin/bash

if [[ "$(whoami)" != "root" ]];then echo -e "[!] Are you root?"; exit 1; fi

allowedAdapters=$(ip -o link show | awk '{print $2}' | cut -d':' -f1)

#Network iface validation (First param)
echo $allowedAdapters | grep $1 &>/dev/null                                         
if [[ $? != 0 ]]; then echo -e "\n[!] Invalid network interfaces | arp.sh <interface>\n"; exit 1; fi

adapter=$1
baseNetParams=$(ip a | grep eth0 | tail -n 1 | awk '{print $2}' )


#Network params obtained ( netWorkid, ip, netmask )
networkId=$(netstat -nr | grep -E "$adapter" | awk '{print $1}' | grep -v '0.0.0.0' )
ip=$(echo $baseNetParams | cut -d "/" -f1)
netmask=$(echo $baseNetParams | cut -d "/" -f2)


# Total hosts calculation based in netmask prefix
less=$((32 - $netmask))
pot=$(echo 2 ^ $less | bc )
totalhosts=$(echo $pot - 3 | bc)

#Creating arp table file
touch ./table.tmp
tableFile="table.tmp"




IFS='.' read a b c d <<< $networkId         #Divide network id in 4 variables
((d=$(echo $networkId | cut -d "." -f4 )))  #First segment number in network id

processCounter=0                            #Limit process      

for host in $(seq 0  $totalhosts ); do      # Calculating possible IP addresses based on the subnet mask

    if (( $processCounter > 50 )); then
        processCounter=0
        wait
    fi

    ((processCounter++))

        ((d++))                         #d variable is first segment
        if ((d > 255)); then
            d=0
            ((c++))

            if ((c > 255));then         #c variable is second segment
                c=0
                ((b++))

                if ((b > 255));then
                    b=0                  #b variable is third segment
                    ((a++))              #a variable is last segment
                    
                fi  
            fi  
        fi

     (
        ip="$a.$b.$c.$d"
        req=$(timeout 0.3 arping -i eth0 -c 1 $ip | grep "60 bytes")                    #ARP request
        mac=$(echo "$req" | awk '{print $4}')
        new="$mac/$ip"

        if [[ $req ]]; then   
            if [[ ! -s $tableFile ]]; then echo $new >> $tableFile; fi                  #Empty table ? put first register !!

            cat $tableFile | grep $new &>/dev/null
            if (($? != 0)); then                                                    # New reg doesn´t exist in table? then..
                cat $tableFile | grep $ip &>/dev/null                                 #   find if ip already exist but with another mac 
                if (($? == 0)); then                                                # if that exist wih another mac then..
                    cat $tableFile | grep -v $ip > $tableFile; echo $new >> $tableFile    #   remove and replace with a another new mac register
                else
                    echo $new >> $tableFile                                           # if doesn't exist push there a new register
                fi
            fi
        fi
     )&
   
done

echo -e "\n     Mac          /   ip    "
cat table.tmp