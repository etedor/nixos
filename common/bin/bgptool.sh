#!/usr/bin/env bash
# bgp.tools whois wrapper
# Usage: bgptool.sh <asn|ip address|mac address>
# Example: bgptool.sh as13335

whois -h bgp.tools " -v $*";
