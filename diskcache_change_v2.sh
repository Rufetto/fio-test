#!/bin/bash
# Created by Rufat Ibragimov on 2017/7/12
# Modified by RyojiK on 2017/7/14
#
# This script takes disk from RAIDIX raid and enable\disable HDD cache
#

echo Script name: $0
echo $# arguments 

#
#Fucnction 
#get all disks UID for the specific RAID array in RAIDIX storage and create an array of UID PARAMS[x]
#
function ChangeWriteCache {
disks=$(rdcli r s -n $1 | grep "drives"| awk '{print $3 }' | sed -s 's/,/ /g')
#RyojiK START
#declare -a PARAMS="( $disks )"
declare -a PARAMS=()
for disk in $disks
do
	if [ "$(echo "$disk" | egrep "[0-9]+-[0-9]+")" != "" ]
	then
		st=$(echo "$disk" | cut -d'-' -f1)
		ed=$(echo "$disk" | cut -d'-' -f2)
		for diski in `seq $st $ed`
		do
			PARAMS=("${PARAMS[@]}" $diski)
		done
	else
		PARAMS=("${PARAMS[@]}" $disk)
	fi
done
#RyojiK END

for element in "${PARAMS[@]}"
    do
	disk=$(rdcli d s -u $element | grep "bdev" | awk '{print $3 }')
	echo "UID=$element	dev=$disk"
    done
echo -n "Enable or Disable disk write cache. (E)nable or (D)disable? (default is Enable): "

read item
case "$item" in
    e|E) echo "Enter «E», enable cache."
	for element in "${PARAMS[@]}"
	    do
		hdd=$(rdcli d s -u $element | grep "dev" | awk '{print $3 }')
		echo "Enable Write Cache on disk UID = $element"
		sdparm --set WCE=1 $hdd
		if [ $? -eq 0 ]; then
		    echo -n "${green}${toend}[OK]"
		else
		    echo -n "${red}${toend}[FAIL]"
		fi
		    echo -n "${reset}"
		    echo 
		    echo "Result sg_mode --page=0x8 $hdd"
		    echo $(sg_modes --page=0x8 $hdd)
		    echo 
	    done
	    echo "************************************************************************"
	    echo "* parameters will be restore to defaults after HDD will be powered off *"
	    echo "************************************************************************"
	    echo -n "Do you want to save parameter permanently?(y/N)"
	    read item
		case "$item" in
		    y|N) echo "Enter «Y», saving parameterse."
			for element in "${PARAMS[@]}"
			    do
				hdd=$(rdcli d s -u $element | grep "dev" | awk '{print $3 }')
				echo "Saving Write Cache parameter on disk UID = $element"
				sdparm --save --set WCE=1 $hdd
			    if [ $? -eq 0 ]; then
			    echo -n "${green}${toend}[OK]"
			    else
			    echo -n "${red}${toend}[FAIL]"
			    fi
			    echo -n "${reset}"
			    echo
			done
			echo "*************************"
			echo "* parameters were saved *"
			echo "*************************"
			exit 0
			;;
		    n|N) echo "Enter «N», do nothing."
			exit 0
			;;
		    *)echo "Do nothing"
			;;
		esac
	
	exit 0
	;;
    d|D) echo "Enter «D», disable cache."
        for element in "${PARAMS[@]}"
	    do
		echo "Disable Write Cache on disk UID = $element"
		hdd=$(rdcli d s -u $element | grep "dev" | awk '{print $3 }')
		sdparm --set WCE=0 $hdd
		if [ $? -eq 0 ]; then
		    echo -n "${green}${toend}[OK]"
		else
		    echo -n "${red}${toend}[FAIL]"
		fi
		    echo -n "${reset}"
		    echo
		    echo "Result sg_mode --page=0x8 $hdd"
		    echo $(sg_modes --page=0x8 $hdd)
		    echo 
	    done
	    echo "************************************************************************"
	    echo "* parameters will be restore to defaults after HDD will be powered off *"
	    echo "************************************************************************"
	    echo
	    echo -n "Do you want to save parameter permanently?(y/N)"
	    read item
		case "$item" in
		    y|N) echo "Enter «Y», saving parameterse."
			for element in "${PARAMS[@]}"
			    do
				hdd=$(rdcli d s -u $element | grep "dev" | awk '{print $3 }')
				echo "Saving Write Cache parameter on disk UID = $element"
				sdparm --save --set WCE=0 $hdd
			    if [ $? -eq 0 ]; then
			    echo -n "${green}${toend}[OK]"
			    else
			    echo -n "${red}${toend}[FAIL]"
			    fi
			    echo -n "${reset}"
			    echo
			done
			echo "*************************"
			echo "* parameters were saved *"
			echo "*************************"
			exit 0
			;;
		    n|N) echo "Enter «N», do nothing."
			exit 0
			;;
		    *)echo "Do nothing"
			;;
		esac
        exit 0
        ;;
    *)   echo "Do nothing"
        ;;
esac
}

#
# end function
#


if [ $# -eq 1 ]; then
	printf "RAID name = %s\n" $1
	if [ $? -eq 0 ]; then
	    echo -n "${green}${toend}[OK]"
	else
	    echo -n "${red}${toend}[fail]"
	    echo "looks like raid-name is wrong"
	    exit
	fi
	    echo -n "${reset}"
	    echo
	ChangeWriteCache $1
    exit
else
    echo "Invalid argument please pass RAID name. \"SCRIPT.SH <RAID name>\""
    exit
fi
