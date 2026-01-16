#!/bin/bash
# Apply DOCKER-USER firewall rules
# This script reads rules.conf and applies iptables rules
# Only affects traffic destined for Docker containers (172.16.0.0/12)

CONFIG_FILE="${CONFIG_FILE:-/home/max/.config/docker-firewall/rules.conf}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "Applying Docker firewall rules from $CONFIG_FILE"

# Flush existing DOCKER-USER rules
iptables -F DOCKER-USER 2>/dev/null || true

# IMPORTANT: Allow all non-Docker traffic to pass through (for ZeroTier forwarding)
# Docker uses 172.17.0.0/16 by default, but can use 172.16.0.0/12 range
iptables -A DOCKER-USER ! -d 172.16.0.0/12 -j RETURN

# Accept established/related connections
iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN

# Read config and apply rules
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
    
    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    
    case "$key" in
        ALLOW_INTERFACE)
            echo "  Allowing interface: $value"
            iptables -A DOCKER-USER -i "$value" -j RETURN
            ;;
        BLOCK_INTERFACE)
            echo "  Blocking interface: $value"
            iptables -A DOCKER-USER -i "$value" -j DROP
            ;;
    esac
done < "$CONFIG_FILE"

# Default: return (allow)
iptables -A DOCKER-USER -j RETURN

echo "Done. Current DOCKER-USER rules:"
iptables -L DOCKER-USER -v --line-numbers
