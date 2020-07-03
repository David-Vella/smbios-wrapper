#!/bin/bash

# 
# Simple wrapper to improve the interface of smbios-thermal-ctl from libsmbios
#
# David Vella, June 2020
# 

parse() {
    local flag=

    while read line; do 
        if [[ $line =~ ^(Balanced|Cool Bottom|Quiet|Performance)$ ]]; then
            if [ $flag ]; then
                echo -n ", $line"
            else
                echo -n "$line"
                flag=true
            fi
        fi
    done

    echo 
}

if [[ $EUID -ne 0 ]]; then 
    echo "error: you cannot perform this operation unless you are root"
    exit 1
fi

if [[ $1 == "-l" ]]; then
    echo -n "Available Modes: "

    parse < <(smbios-thermal-ctl -i)

elif [[ $1 == "-s" ]]; then

    if [[ $2 =~ ^[Bb][alanced]*$ ]]; then
        REQUESTED="balanced"

    elif [[ $2 =~ ^[Cc][ool]*$ ]]; then
        REQUESTED="cool-bottom"

    elif [[ $2 =~ ^[Qq][uiet]*$ ]]; then
        REQUESTED="quiet"

    elif [[ $2 =~ ^[Pp][erformance]*$ ]]; then
        REQUESTED="performance"

    else
        echo "error: invalid mode"
        exit 1
    fi

    smbios-thermal-ctl --set-thermal-mode=$REQUESTED > /dev/null

    echo "Thermal Mode Set Successfully to: $REQUESTED"

elif [[ $1 == "-c" ]]; then
    echo -n "Current Thermal Mode: "

    parse < <(smbios-thermal-ctl -g)

else
    echo "usage: tm [-l] [-s <mode>] [-c]"
fi
