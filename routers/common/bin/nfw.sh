#!/usr/bin/env bash
# Watch log messages from the nftables firewall
# Usage: nfw.sh [filters]
# Example: nfw.sh --chain=input --dpt=23

get_color() {
    # Get a color code for the given string
    local str="$1"
    local color_code=$(($(echo -n "$str" | cksum | cut -f1 -d' ') % 6 + 31))
    echo "$color_code"
}

colorize_values() {
    # Colorize the values of the key=value pairs
    local entry="$1"
    for word in $entry; do
        if [[ "$word" == *=* ]]; then
            key="${word%=*}"
            value="${word#*=}"

            color=$(get_color "$value")

            printf "%s=\033[%sm%s\033[0m " "$key" "$color" "$value"
        else
            printf "%s " "$word"
        fi
    done
    echo ""
}

filter_line() {
    local line="$1"
    for arg in "${filters[@]}"; do
        key="${arg%=*}"
        value="${arg#*=}"
        # Convert to lowercase and check if the line contains the key=value pair
        if [[ "${line,,}" != *"${key,,}=${value,,}"[[:space:]]* ]] && [[ "${line,,}" != *"${key,,}=${value,,}"$ ]]; then
            return 1
        fi
    done
    return 0
}

# Construct a list of filters from the arguments
filters=()
while [[ $# -gt 0 ]]; do
    arg="$1"
    shift
    if [[ "$arg" == "--"*"="* ]]; then
        # This handles --key=value format
        field="${arg#--}"
        field="${field%=*}"
        value="${arg#*=}"
        filters+=("$field=$value")
    elif [[ "$arg" == "--"* ]]; then
        # This handles --key value format
        field="${arg#--}"
        value="$1"
        shift
        filters+=("$field=$value")
    fi
done

# Read dmesg output line by line
while IFS= read -r line; do
    if [[ "$line" == *nftables* ]]; then
        if filter_line "$line"; then
            colorize_values "$line"
        fi
    fi
done < <(dmesg -wT --since "0 second ago")
