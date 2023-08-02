#!/usr/bin/env bash
# Rebuild a NixOS system configuration from a flake.
# Usage: flake-rebuild.sh <options>
# Example: flake-rebuild.sh switch

sudo nixos-rebuild "$@" --flake ".#$(hostname)" || sudo nixos-rebuild "$@" --flake "/etc/nixos#$(hostname)"
