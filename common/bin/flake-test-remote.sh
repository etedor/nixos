#!/usr/bin/env bash
# Rebuild a remote NixOS system configuration from a flake.
# Usage: flake-test-remote.sh <flake> <hostname>
# Example: flake-test-remote.sh nix-router-sea 10.99.0.0

git add :/
nixos-rebuild test --flake ".#$1" --target-host "root@$2"
git reset
