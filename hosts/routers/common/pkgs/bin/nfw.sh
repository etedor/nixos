#!/usr/bin/env bash
# Watch log messages from the nftables firewall
# Usage: nfw.sh [filters] [--full]
# Example: nfw.sh --chain=input --dpt=23 --full

# Fields to be displayed by default
DEFAULT_FIELDS="CHAIN RULE IN OUT SRC DST PROTO SPT DPT"

get_color() {
    local str="$1"
    local color_code=$(($(echo -n "$str" | cksum | cut -f1 -d' ') % 6 + 31))
    echo "$color_code"
}

colorize_values() {
    local entry="$1"
    for word in $entry; do
        if [[ "$word" == *=* ]]; then
            key="${word%=*}"
            value="${word#*=}"

            # If full output or key is in the default fields, then colorize and display
            if $FULL_OUTPUT || [[ " $DEFAULT_FIELDS " == *" $key "* ]]; then
                color=$(get_color "$value")
                printf "%s=\033[%sm%s\033[0m " "$key" "$color" "$value"
            fi
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
        if [[ "${line,,}" != *"${key,,}=${value,,}"[[:space:]]* ]] && [[ "${line,,}" != *"${key,,}=${value,,}"$ ]]; then
            return 1
        fi
    done
    return 0
}

# Construct a list of filters from the arguments
filters=()
FULL_OUTPUT=false

while [[ $# -gt 0 ]]; do
    arg="$1"
    shift
    case "$arg" in
        --full)
            FULL_OUTPUT=true
            ;;
        --*=*)
            # This handles --key=value format
            field="${arg#--}"
            field="${field%=*}"
            value="${arg#*=}"
            filters+=("$field=$value")
            ;;
        --*)
            # This handles --key value format
            field="${arg#--}"
            value="$1"
            shift
            filters+=("$field=$value")
            ;;
    esac
done

# Read dmesg output line by line
while IFS= read -r line; do
    if [[ "$line" == *nftables* ]]; then
        if filter_line "$line"; then
            colorize_values "$line"
        fi
    fi
done < <(dmesg -wT --since "0 second ago")
