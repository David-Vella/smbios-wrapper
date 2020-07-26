#!/bin/bash

#
# Simple wrapper to improve the interface of smbios-thermal-ctl from libsmbios
#
# David Vella, June 2020
#

function check_perm {
    if [ $EUID -ne 0 ]; then 
        echo "error: you cannot perform this operation unless you are root"
        exit 1
    fi
}

function check_args {
    if [ $1 -lt $2 ]; then
        echo "error: to few arguments"
        exit 1
    elif [ $1 -gt $2 ]; then
        echo "error: to many arguments"
        exit 1
    fi
}

function find_modes {
    local flag=0

    smbios-thermal-ctl -i | while read line; do
        if [ "$line" == "Supported Thermal Modes:" ]; then
            flag=1
        elif [ -z "$line" ]; then
            flag=0
        elif [ $flag -eq 1 ]; then
            echo ${line/ /-}
        fi
    done
}

function print_modes {
    local flag=0

    find_modes | while read line; do 
        if [ $flag -eq 0 ]; then
            flag=1
            echo -n $line
        elif [ $flag -ne 0 ]; then
            echo -n ", $line"
        fi
    done
    echo
}

function get_mode {
    local flag=0

    smbios-thermal-ctl -g | while read line; do
        if [ "$line" == "Current Thermal Modes:" ]; then
            flag=1
        elif [ -z "$line" ]; then
            flag=0
        elif [ $flag -ne 0 ]; then
            find_modes | while read mode; do
                if [ "${line/ /-}" == "$mode" ]; then
                    echo $mode
                fi
            done
        fi
    done
}

# ==================== Main ==================== #

if [ -z "$(find_modes)" ]; then
    echo "error: failed to find any available thermal modes"
    exit 1
fi

if [ "$1" == "-l" ]; then
    check_perm
    check_args $# 1

    MODES=$(print_modes)
    echo "Available Modes: $MODES"

elif [ "$1" == "-s" ]; then
    check_perm
    check_args $# 2

    OLD=$(get_mode)

    if [[ "${OLD,,}" == "${2,,}"* ]]; then
        echo "error: Thermal Mode Already Set to $OLD"
        exit 1
    fi

    find_modes | while read mode; do
        if [[ "${mode,,}" == "${2,,}"* ]]; then
            smbios-thermal-ctl --set-thermal-mode=$mode > /dev/null
            echo "Thermal Mode Set Successfully to: $mode"
        fi
    done

    NEW=$(get_mode)

    if [ "$OLD" == "$NEW" ]; then
        echo "error: Failed to Set Thermal Mode to $2"
        exit 1
    fi

elif [ "$1" == "-c" ]; then
    check_perm
    check_args $# 1

    CURRENT=$(get_mode)
    echo "Current Thermal Mode: $CURRENT"

elif [ "$1" == "-h" ]; then
    echo "A wrapper to improve the smbios-thermal-ctl interface"
    echo "  tm -c         :  print the current thermal mode"
    echo "  tm -l         :  list available thermal modes"
    echo "  tm -s <mode>  :  set the thermal mode"
    echo "  tm -h         :  display this help screen"

else
    echo "usage: tm < -l | -s <mode> | -c >"
    echo "use tm -h for help"
    exit 1
fi
