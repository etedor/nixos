#!/usr/bin/env bash
# Run a command in vtysh.
# Usage: sho.sh <command>
# Example: sho.sh ip bgp summary

sudo vtysh -c "show $*"
