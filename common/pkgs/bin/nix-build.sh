#!/usr/bin/env bash
# Rebuild or test the NixOS system configuration.
# Usage: nix-build.sh <action> [<flake name> <target host>]
# Example: nix-build.sh test

action=$1

if [[ "${action}" != "test" && "${action}" != "switch" ]]; then
    echo "Invalid action. Choose 'test' or 'switch'."
    exit 1
fi

if [[ "${action}" == "test" ]]; then
    git add :/
fi

if [[ $# -eq 1 ]]; then
    # Local action
    if [[ "${action}" == "test" ]]; then
        sudo nixos-rebuild test --flake ".#$(hostname)"
    else
        sudo nixos-rebuild switch --flake "/etc/nixos#$(hostname)"
    fi
else
    # Remote action
    flake_name=$2
    target_host=$3
    if [[ "${action}" == "test" ]]; then
        nixos-rebuild "${action}" --flake ".#${flake_name}" --target-host "root@${target_host}"
    else
        nixos-rebuild "${action}" --flake "/etc/nixos#${flake_name}" --target-host "root@${target_host}"
    fi
fi

if [[ "${action}" == "test" ]]; then
    git reset
fi
