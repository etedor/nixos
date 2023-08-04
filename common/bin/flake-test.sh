#!/usr/bin/env bash
# Test a NixOS system configuration from a flake.
# Usage: flake-test.sh
# Example: flake-test.sh

git add :/
sudo nixos-rebuild test --flake ".#$(hostname)"
git reset
