#!/usr/bin/env bash
# Clone a NixOS configuration from a git repository.
# Usage: nixos-clone.sh <git repository>
# Example: nixos-clone.sh git@github.com:etedor/nixos.git

set -e

tmp_dir=$(mktemp -d)
git clone "$1" "${tmp_dir}"
sudo rm -r /etc/nixos/* || true
sudo cp -r "${tmp_dir}"/* /etc/nixos/
sudo chown -R root:root /etc/nixos
