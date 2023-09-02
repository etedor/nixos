#!/usr/bin/env bash
# Generate a WireGuard client configuration.
# Usage: wg-mkclient.sh --client-name <name> --client-ip <client IP> --tunnel <wg interface>
# Example: wg-mkclient.sh --client-name pine --client-ip 10.99.1.11 --tunnel wg1

set -e

# Initialize arguments
CLIENT_NAME=""
CLIENT_IP=""
TUNNEL=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --client-name | --name)
        CLIENT_NAME="$2"
        shift
        ;;
    --client-ip | --ip)
        CLIENT_IP="$2"
        shift
        ;;
    --tunnel | --tun)
        TUNNEL="$2"
        shift
        ;;
    *)
        echo "Unknown parameter: $1"
        exit 1
        ;;
    esac
    shift
done

# Check if all arguments are provided
if [[ -z "$CLIENT_IP" ]] || [[ -z "$TUNNEL" ]] || [[ -z "$CLIENT_NAME" ]]; then
    echo "Usage: $0 --client-name <name> --client-ip <IP> --tunnel <wg interface>"
    exit 1
fi

TEMP_CONF=$(mktemp /tmp/wgclient.conf.XXXXXX)

CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)

SERVER_PUB_KEY=$(sudo wg show "$TUNNEL" public-key)
SERVER_IP=$(ip -4 addr show ens3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tail -n1)
SERVER_PORT=$(sudo wg show "$TUNNEL" listen-port)

cat >"${TEMP_CONF}" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_IP}/32
DNS = 10.0.1.1

[Peer]
PublicKey = ${SERVER_PUB_KEY}
AllowedIPs = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
Endpoint = ${SERVER_IP}:${SERVER_PORT}
EOF

cat "${TEMP_CONF}"
printf "\n"
qrencode -t ansiutf8 <"${TEMP_CONF}"

printf "\nNixOS configuration for the new peer:\n\n"
printf "          {\n"
printf "            wireguardPeerConfig = {\n"
printf "              # %s\n" "${CLIENT_NAME}"
printf "              PublicKey = \"%s\";\n" "${CLIENT_PUB_KEY}"
printf "              AllowedIPs = [ \"%s/32\" ];\n" "${CLIENT_IP}"
printf "            };\n"
printf "          }\n"

rm -f "${TEMP_CONF}"
