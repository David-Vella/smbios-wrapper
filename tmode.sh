#!/bin/bash

#
# Simple wrapper to improve the interface of smbios-thermal-ctl from libsmbios
#
# David Vella, June 2020
#

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

    echo -n "Available modes: "

    for line in $(find_modes); do 
        if [ $flag -eq 0 ]; then
            flag=1
            echo -n $line
        elif [ $flag -ne 0 ]; then
            echo -n ", $line"
        fi
    done
    echo
}

function compare_modes {
    if [[ "${1,,}" == "${2,,}"* ]]; then
        return $(true)
    else
        return $(false)
    fi
}

function get_mode {
    local flag=0

    smbios-thermal-ctl -g | while read line; do
        if [ "$line" == "Current Thermal Modes:" ]; then
            flag=1
        elif [ -z "$line" ]; then
            flag=0
        elif [ $flag -ne 0 ]; then
            for mode in $(find_modes); do
                if [ "${line/ /-}" == "$mode" ]; then
                    echo $mode
                fi
            done
        fi
    done
}

function check_mode {
    local requested=$1

    for mode in $(find_modes); do
        if compare_modes $mode $requested; then
            return $(true)
        fi
    done

    return $(false)
}

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

function check_sys {
    if [ -z "$(find_modes)" ]; then
        echo "error: failed to find any available thermal modes"
        exit 1
    fi
}

# ==================== Main ==================== #

if [ "$1" == "-l" ]; then
    check_perm
    check_sys
    check_args $# 1

    print_modes

elif [ "$1" == "-s" ]; then
    check_perm
    check_sys
    check_args $# 2

    REQUESTED_MODE=$2
    OLD_MODE=$(get_mode)

    if ! check_mode $REQUESTED_MODE; then
        echo "error: Invalid Thermal Mode"
        print_modes
        exit 1
    fi

    if compare_modes $OLD_MODE $REQUESTED_MODE; then
        echo "error: Thermal Mode Already Set to: $OLD_MODE"
        exit 1
    fi

    for mode in $(find_modes); do
        if compare_modes $mode $REQUESTED_MODE; then
            smbios-thermal-ctl --set-thermal-mode=$mode &> /dev/null
            echo "Thermal Mode Set Successfully to: $mode"
        fi
    done

    NEW_MODE=$(get_mode)

    if [ "$OLD_MODE" == "$NEW_MODE" ]; then
        echo "error: Failed to Set Thermal Mode to: $REQUESTED_MODE"
        exit 1
    fi

elif [ "$1" == "-c" ]; then
    check_perm
    check_sys
    check_args $# 1

    CURRENT=$(get_mode)
    echo "Current Thermal Mode: $CURRENT"

elif [ "$1" == "-h" ]; then
    echo "A wrapper to improve the smbios-thermal-ctl interface"
    echo "  tmode -c         :  print the current thermal mode"
    echo "  tmode -l         :  list available thermal modes"
    echo "  tmode -s <mode>  :  set the thermal mode"
    echo "  tmode -h         :  display this help screen"

else
    echo "usage: tmode < -l | -s <mode> | -c >"
    echo "use tmode -h for help"
    exit 1
fi
