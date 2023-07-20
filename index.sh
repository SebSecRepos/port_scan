#!/bin/bash

#colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


(


    echo -e "${redColour}
                          ⢀⡴⠟⠛⠛⠛⠛⠛⢦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣦⡀⠀⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠀⣰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⣆⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⠘⡇⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⢘⡧⠀⠀⢀⣀⣤⡴⠶⠶⢦⣤⣀⡀⠀⠀  ⢻⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⠀⠀⠘⣧⡀⠛⢻⡏⠀⠀⠀⠀⠀⠀⠉⣿⠛⠂⣼⠇⠀⠀⠀⠀⠀⠀
                ⠀⠀⠀⠀⢀⣤⡴⠾⢷⡄⢸⡇⠀⠀⠀⠀⠀⠀⢀⡟⢀⡾⠷⢦⣤⡀⠀⠀⠀⠀
                ⠀⠀⠀⢀⡾⢁⣀⣀⣀⣻⣆⣻⣦⣤⣀⣀⣠⣴⣟⣡⣟⣁⣀⣀⣀⢻⡄⠀⠀⠀
                ⠀⠀⢀⡾⠁⣿⠉⠉⠀⠀⠉⠁⠉⠉⠉⠉⠉⠀⠀⠈⠁⠈⠉⠉⣿⠈⢿⡄⠀⠀
                ⠀⠀⣾⠃⠀⣿⠀⠀⠀⠀⠀⠀⣠⠶⠛⠛⠷⣤⠀⠀⠀⠀⠀⠀⣿⠀⠈⢷⡀⠀
                ⠀⣼⠃⠀⠀⣿⠀⠀⠀⠀⠀⢸⠏⢤⡀⢀⣤⠘⣧⠀⠀⠀⠀⠀⣿⠀⠀⠈⣷⠀
                ⢸⡇⠀⠀⠀⣿⠀⠀⠀⠀⠀⠘⢧⣄⠁⠈⣁⣴⠏⠀⠀⠀⠀⠀⣿⠀⠀⠀⠘⣧
                ⠈⠳⣦⣀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠻⠶⠶⠟⠀⠀⠀⠀⠀⠀⠀⣿⠀⢀⣤⠞⠃
                ⠀⠀⠀⠙⠷⣿⣀⣀⣀⣀⣀⣠⣤⣤⣤⣤⣀⣤⣠⣤⡀⠀⣤⣄⣿⡶⠋⠁⠀⠀
                ⠀⠀⠀⠀⠀⢿⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣿⠀⠀⠀
                ⠀
          ========= Bienvenido/a a Port scan ==========⠀    

${endColour}"

sleep 1


base_ifaces=$(ifconfig | grep "flags" | grep -v "LOOPBACK" | cut -d ":" -f1)
menuOpt=""
selectedIface="No seleccionado"   #Interfaz seleccionada sin mas detalles

#variables del adaptador
declare -i netPrefix=0
declare -i base=0
declare -i ips=0
hosts=0
ip=0
netmask=0
netsOct=0
hostsOct=0
hostInNetToScann=""
selectedIp="No selected"


function ctrl_c(){
    clear
    echo -e "${redColour}\n \n [+] Saliendo...${endColour}"
    tput cnorm; exit 1 #recuperar cursor
}

trap ctrl_c INT


function arpDiscover(){ 
    clear
    processCounter=0;

    echo -e "\n \t           ${greenColour} IP /${redColour} mac            |       ${turquoiseColour}SO${endColour}"
    echo -e "${redColour}----------------------------------------------------------------------------- ${endColour}"

    echo -e "$1" | while read -r line
        do
            if [ $processCounter > 50 ]; then
                wait
                processCounter=0
            fi;
            (($processCounter++));
            ( 
                ip=$(echo $line | awk '{print $1}' )
                mac=$(echo $line | awk '{print $3}')
                ttl=$(timeout 0.3 ping -c 1 "$ip" | grep "ttl" | awk '{print $6}' | tr -d "ttl=" &) 
                so=""

                if [ "$ttl" ]; then

                    if [ "${ttl}" == "64" ]; then
                        so="${purpleColour}Linux/Android/Mac  ${endColour}"
                    elif [ "${ttl}" == "255" ]; then
                        so=" Unix/Linux/FreeBSD/macOS"
                    elif [ "${ttl}" == "32" ] || [ "${ttl}" == "128" ]; then
                        so="${turquoiseColour} Windows ${endColour}"
                    fi
                    echo -e "\n \t ${greenColour} $ip / ${redColour}$mac  ${grayColour}  ( $so / ttl --> $ttl) ${endColour}"  
                else
                    echo -e "\n \t ${greenColour} $ip / ${redColour}$mac  ${grayColour}  ( ttl Desconocido)"  
                fi
            )&
        done;
    sleep 2
    echo -e "\n"
    echo -e "\n"
    echo -e "${greenColour}===========================  Información  ===================================${endColour}\n"
    echo -e " \t ${greenColour}[Colocar ip]${endColour} ---> ${grayColour}Seleccionar un equipo${endColour}"
    echo -e "\n \t ${redColour}[0]${endColour} ---> Atras \n"
    echo -e "${turquoiseColour}\n (ctrl + mayus + up) Para subir  \n ${endColour}"

}

function validateSelectedIp(){

    echo $1| grep $2  | grep -vE "IP|mac|SO" 
    if [ $? -ne 0 ]; then
        echo "Opción inválida (Saliendo al menú..)"
    else
        echo "isvalid es $isValid"
        clear
        echo -e "${grayColour} \n  ------------------------------------------------- \n${endColour}"
        echo -e "${greenColour} \n \t  ¡Host ${yellowColour} ${2} ${endColour} ${greenColour}seleccionado!\n ${endColour}"
        echo -e "${grayColour} \n ------------------------------------------------- \n${endColour}"
        echo "Presione una tecla ir al menú de escaneo"
        read -rs -p"";echo
        
        optionsScann "$2"
        select_scann "$2"
    fi

}


function selectIface(){  #Función que selecciona la interfaz
    clear
    declare -i index=0  
    declare -i number=0

    echo -e "${purpleColour}------------  Adaptadores disponibles  ----------------\n\n${endColour}"

    listed_ifaces=$(echo -e "$base_ifaces" | while read line; do
        index+=1
        echo -e "\t ${greenColour}[$index]${endColour} ${grayColour} ---> $line ${endColour}"
    done
    )

    echo -e "$listed_ifaces"
    echo -e "\n \t ${greenColour}[0]${endColour} ${grayColour}---> Atras..${endColour}"
    echo -e "\n" 
    echo -e "${purpleColour}--------------------------------------------------------${endolour}\n"
    echo -e "${grayColour}[!] Seleccione opción por número: \n${endColour}"

    read number

    selectedIface="$( echo -e "$listed_ifaces" | grep -F "[$number]" | awk '{print $4}')" #Al grepear [$number], no falla la validación

    if [ $number -eq 0 ]; then
        selectedIface="No seleccionado"
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
        clear
    elif [ ${#selectedIface} -gt 0 ]; then
        clear
        #Seleccionada la interfaz, asignamos las variables de red
        echo -e "${grayColour}\n ------------------------------------------------- \n${endColour}"
        echo -e "${greenColour}\n ¡Adaptador ${selectedIface} seleccionado!\n${endColour}"
        echo -e "${grayColour}\n ------------------------------------------------- \n${endColour}"

        ip=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $2}')
        netmask=$(ifconfig $selectedIface | head -n 2 | tail -n 1 | awk '{print $4}')
        netPrefix=$(ip a | grep $selectedIface | tail -n 1 | awk '{print $2}' | cut -d "/" -f2)
		netIp=$(ip route | grep "proto kernel" | awk '{print $1}' | cut -d "/" -f1 )
        let base="32 - $netPrefix"

        let ips=$( echo "2 ^ $base" | bc ) 
        let hosts="$ips - 2"
        baseIp=0

        if [ $netPrefix -le 8 ]; then
            netsOct=1
        elif [ $netPrefix -le 16 ]; then
            netsOct=2
        elif [ $netPrefix -le 24 ]; then
            netsOct=3
        fi

        baseIp=$( echo "$ip" | cut -d "." -f1-${netsOct})
        let hostsOct="4 - $netsOct"
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
        clear
    else
        echo "[!] No existe la interfaz"
        selectedIface="No seleccionado"
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
        clear
        selectIface
    fi
}  

function ifaceInfo(){  #Muestra información de la interfaz
    clear
    if [ "$selectedIface" != "No seleccionado" ];
    then
   
        echo -e "${turquoiseColour}\n -------------- Información de adaptador ${yellowColour}[ $selectedIface ]${endColour} ${turquoiseColourColour}---------------\n\n${endColour}"
        echo -e "\t ${greenColour}IP:${grayColour} $ip \n ${endColour}"
        echo -e "\t ${greenColour}Máscara de subred:${grayColour} $netmask /$netPrefix\n${endColour}"
        echo -e "\t ${greenColour}Cantidad posible de host:${grayColour} $hosts \n${endColour}"

        echo -e "${turquoiseColour}\n -----------------------------------------------------------------------------\n${endColour}"
        echo "Presione una tecla para continuar"
        read -rs -p" Presione";echo
        clear
    else
        clear
    fi
}

function host_list(){ #Escaneo en búsqueda de dispositivos dentro de la red
    clear

    if [ "$selectedIface" != "No seleccionado" ];then

            selectedIp="No selected"
            allHosts=$(arp | grep -v "Address") 

            arpDiscover "$allHosts"
            
            read selectedIp


            case $selectedIp in
                0)  
                    selectedIp="No selected"
                    clear
                ;;
                *)
                    validateSelectedIp "$allHosts" "$selectedIp"
                ;;
            esac

        else
            clear
        fi
}

function optionsScann(){
    clear
    echo -e "${redColour}\n---------------------  Seleccionar tipo de escaneo  ------------------------------${endColour}"
    echo -e "${redColour}\n                        Detectando puertos ${grayColour}[ $1 ] ${endColour}${redColour} \n ${endColour}"
    echo -e "${redColour}------------------------------------------------------------------------------------\n ${endColour}"
    echo -e " \t ${greenColour}[1] ${endColour} ${grayColour} Básico \n ${endColour}"
    echo -e " \t ${greenColour}[2] ${endColour} ${grayColour} Escaneo profundo \n ${endColour}"
    echo -e " \t ${greenColour}[0] ${endColour} ${grayColour} atras.. \n ${endColour}"
    echo -e "${redColour} \n---------------------------------  Información  ----------------------------------------------\n ${endColour}"
    echo -e "${greenColour} \n [1]  -  Utilizá un diccionario de puertos\n ${endColour}"
    echo -e "${greenColour} \n [2]  -  Asegurese que su equipo cuenta con los recursos necesarios [ son 65536 puertos ] (Solo un equipo por escaneo)\n ${endColour}"
    echo -e "${grayColour} \n Seleccione una opción\n ${endColour}"

}


function select_scann(){
    scann_type=""
    read scann_type

    case $scann_type in
        1)  
            escaneo_base $1
            host_list
        ;;
        2)
            
            escaneo_extenso 
            host_list
        ;;
        0)
            clear
        ;;
        *)
            optionsScann $1
            echo -e "\n Opción inválida \n"
            read scann_type
        ;;
        esac
}

function escaneo_base(){
	clear

	   echo "${yellowColour}======== Escaneo básico TCP ==========${endColour}"
		hostWithPorts="0"
        clear
        tput bold; echo -e "${redColour} [!] ${endColour} Escaneando puertos, espere porfavor ..."
		

            echo -e "${yellowColour}\n--------- Resultados host [ $1 ]--------\n${endColour}" | tee ./portLog.txt
            cat ./portList.txt | while read -r port;
                do
                    ((timeout 1 echo "" > /dev/tcp/$1/$port)2>/dev/null && echo -e "${greenColour}\n \t Port $port TCP --> open${endColour}" | tee -a ./portLog.txt) &
                done; wait
                sleep 0.001
            
            sleep 1
            echo -e "\n${blueColour} Finalizando escaneo..${endColour}\n"
            sleep 3
            echo -e "\n ${redColour}No hay mas puertos abiertos${endColour} \n"    

        echo "Presiona una tecla para continuar"
        read -rs -p "pres ";echo 
        clear
 
}

function escaneo_extenso(){
	clear
    if [ ${#hostInNetToScann} -le 5 ]; then
        clear
    else
        
        tput cnorm; echo -e "\n ${redColour} [!] Escaneando los 65536 puertos posibles, esto demorará mucho ... ${yellowColour} \n\n------------ Resultados host [ $hostInNetToScann ] ------------\n\n${endColour}"   
        echo -e " ${blueColour} Si el escaneo demora demasiado salir con ctrl + c ${endColour}"
        echo -e "\t ${yellowColour} \n\n------------ Resultados host [ $hostInNetToScann ] ------------\n\n${endColour}" > ./portLog.txt
        for port in $(seq 1 65536);
		do  
            (( timeout 1 echo "" > "/dev/tcp/$hostInNetToScann/$port")2>/dev/null && echo -e "\t \n ${greenColour}Port $port TCP --> open \n${endColour}" | tee -a ./portLog.txt) &
            sleep 0.001
        done; wait
        sleep 1
        echo -e "\n${blueColour} Finalizando escaneo..${endColour}\n"
        sleep 3
        echo -e "\n ${redColour}No hay mas puertos abiertos${endColour} \n"
    
        echo "Presiona una tecla para continuar"
        read -rs -p "pres ";echo 
        tput cnorm
        clear
    fi
}



function ifacesopt(){  #Muestra las opciones y elige el menú
    echo -e "${purpleColour}\n------------  Adaptador actual:${endColour} ${grayColour}[ $selectedIface ]${endColour} ${purpleColour}------------------\n\n${endColour}"
    echo -e "\t ${greenColour}[ 1 ]${endColour} ---> Seleccionar adaptador de red \n"
    echo -e "\t ${greenColour}[ 2 ]${endColour} ---> Ver log último escaneo \n"

    if [ "$selectedIface" != "No seleccionado" ]; then
        echo -e "\t ${greenColour}[ 3 ]${endColour} ${grayColour}---> Escanear equipos de la red \n${endColour}"
        echo -e "\t ${greenColour}[ 4 ]${endColour} ${grayColour}---> Ver información del adaptador de red${endColour}"
    fi
    echo -e "\n \t ${redColour}[ 0 ]${endColour} ---> Salir \n\n"
    echo -e "${purpleColour}--------------------------------------------------------------\n${endColour}"
    echo -e "${grayColour}Elija una opción:${endColour}"
}




function menuifaces(){
    clear
    case $menuOpt in
        1) 
            selectIface
            ifacesopt
            read menuOpt
        ;;
        2) 
            clear
            cat ./portLog.txt
            echo -e "${turquoiseColour}\n (ctrl + mayus + up) Para subir en el archivo \n ${endColour}"
            echo "Presione una tecla para continuar"
            read -s -p"pre";echo 
            clear
            ifacesopt
            read menuOpt
        ;;
        3) 
            host_list
            ifacesopt
            read menuOpt
        ;;
        4) 
            ifaceInfo
            ifacesopt
            read menuOpt
        ;;
        "")
            ifacesopt
            read menuOpt
        ;;
        0) 
            exit 0
        ;;
        *)
            echo "Opción inválida"
            ifacesopt
            read menuOpt
        ;;
    esac

}





while [ true ]; do
    clear
    menuifaces
done

)2>/dev/null
