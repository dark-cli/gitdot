#!/bin/bash
# Firewall & Security Check Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

echo "========================================"
echo "   Firewall & Security Status Check"
echo "========================================"
echo ""

# 1. SELinux
echo "── SELinux ──"
SELINUX=$(getenforce 2>/dev/null)
if [[ "$SELINUX" == "Enforcing" ]]; then
    pass "SELinux: Enforcing"
elif [[ "$SELINUX" == "Permissive" ]]; then
    warn "SELinux: Permissive (reduced security)"
else
    fail "SELinux: Disabled"
fi

# 2. Firewalld
echo ""
echo "── Firewalld ──"
if systemctl is-active --quiet firewalld; then
    pass "Firewalld: Running"
else
    fail "Firewalld: Not running"
fi

if systemctl is-enabled --quiet firewalld; then
    pass "Firewalld: Enabled on boot"
else
    fail "Firewalld: Not enabled on boot"
fi

# 3. Zones
echo ""
echo "── Active Zones ──"
ZONES=$(sudo firewall-cmd --get-active-zones 2>/dev/null)
if echo "$ZONES" | grep -q "zerotier"; then
    pass "ZeroTier zone: Active"
else
    fail "ZeroTier zone: Not active"
fi

if echo "$ZONES" | grep -q "public"; then
    pass "Public zone: Active"
else
    fail "Public zone: Not active"
fi

if echo "$ZONES" | grep -q "docker"; then
    pass "Docker zone: Active"
else
    warn "Docker zone: Not active (may be OK)"
fi

# 4. Policies
echo ""
echo "── Forwarding Policies ──"
POLICIES=$(sudo firewall-cmd --get-policies 2>/dev/null)
if echo "$POLICIES" | grep -q "zerotier-to-lan"; then
    pass "zerotier-to-lan policy: Exists"
else
    fail "zerotier-to-lan policy: Missing"
fi

if echo "$POLICIES" | grep -q "lan-to-zerotier"; then
    pass "lan-to-zerotier policy: Exists"
else
    fail "lan-to-zerotier policy: Missing"
fi

# 5. Masquerade (NAT)
echo ""
echo "── NAT / Masquerade ──"
if sudo firewall-cmd --zone=public --query-masquerade 2>/dev/null | grep -q "yes"; then
    pass "Masquerade on public zone: Enabled"
else
    fail "Masquerade on public zone: Disabled"
fi

# 6. Docker-firewall service
echo ""
echo "── Docker Firewall Service ──"
if systemctl is-active --quiet docker-firewall; then
    pass "docker-firewall: Running"
else
    fail "docker-firewall: Not running"
fi

if systemctl is-enabled --quiet docker-firewall; then
    pass "docker-firewall: Enabled on boot"
else
    fail "docker-firewall: Not enabled on boot"
fi

# 7. DOCKER-USER rules
echo ""
echo "── DOCKER-USER iptables Rules ──"
DOCKER_RULES=$(sudo iptables -L DOCKER-USER -v -n 2>/dev/null)
if echo "$DOCKER_RULES" | grep -q "zt\+"; then
    pass "ZeroTier allowed in DOCKER-USER"
else
    fail "ZeroTier NOT in DOCKER-USER rules"
fi

if echo "$DOCKER_RULES" | grep -qE "DROP.+enp9s0"; then
    pass "External interface blocked in DOCKER-USER"
else
    fail "External interface NOT blocked in DOCKER-USER"
fi

# 8. Stealth mode (ICMP)
echo ""
echo "── Stealth Mode (Ping) ──"
RICH_RULES=$(sudo firewall-cmd --zone=public --list-rich-rules 2>/dev/null)
if echo "$RICH_RULES" | grep -q "icmp-type.*echo-request.*drop"; then
    pass "Stealth mode: Enabled (ping dropped)"
else
    warn "Stealth mode: Disabled (ping visible)"
fi

# 9. Docker containers
echo ""
echo "── Docker Containers ──"
for container in ollama open-webui navidrome; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        pass "$container: Running"
    else
        fail "$container: Not running"
    fi
done

echo ""
echo "========================================"
echo "   Check complete!"
echo "========================================"
