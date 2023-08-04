#!/usr/bin/env bash
# Run a command in the birdc shell.
# Usage: sho.sh <command>
# Example: sho.sh ip bgp summary

sudo birdc "show $*"
