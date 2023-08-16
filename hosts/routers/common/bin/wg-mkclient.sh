#!/usr/bin/env bash
# Generate a WireGuard client configuration.
# Usage: wg-mkclient.sh <client IP> <wg interface>
# Example: wg-mkclient.sh 10.99.1.11 wg1

set -e

if [[ -z $1 ]] || [[ -z $2 ]]; then
    echo "Usage: $0 <client IP> <wg interface>"
    exit 1
fi

TEMP_CONF=$(mktemp /tmp/wgclient.conf.XXXXXX)

CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)

PEER_PUB_KEY=$(sudo wg show "$2" public-key)
PEER_IP=$(ip -4 addr show ens3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
PEER_PORT=$(sudo wg show "$2" listen-port)

cat >"${TEMP_CONF}" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = $1/32
DNS = 10.0.1.1

[Peer]
PublicKey = ${PEER_PUB_KEY}
AllowedIPs = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
Endpoint = ${PEER_IP}:${PEER_PORT}
EOF

cat "${TEMP_CONF}"
printf "\n"
qrencode -t ansiutf8 <"${TEMP_CONF}"

printf "\nNixOS configuration for the new peer:\n"
printf "        {\n"
printf "          # peer-name\n"
printf "          publicKey = \"%s\";\n" "${CLIENT_PUB_KEY}"
printf "          allowedIPs = [ \"%s/32\" ];\n" "${1}"
printf "        }\n"

rm -f "${TEMP_CONF}"
