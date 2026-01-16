# Firewalld Configuration

Personal firewall setup for Fedora with:
- Services only accessible via ZeroTier VPN + localhost
- ZeroTier gateway for accessing home LAN and internet remotely
- Stealth mode (invisible to ping)
- Docker container protection via DOCKER-USER rules

## Quick Commands

```bash
# Check everything is working
~/.config/firewalld/check.sh

# Apply config changes
~/.config/firewalld/update.sh

# Apply Docker firewall rules
sudo ~/.config/docker-firewall/apply-rules.sh
```

## Directory Structure

```
~/.config/firewalld/
├── README.md              # This file
├── check.sh               # Status check script
├── update.sh              # Apply config changes
├── zones/
│   ├── zerotier.xml       # ZeroTier interface - services allowed
│   ├── public.xml         # External interface - restrictive + NAT
│   └── docker.xml         # Docker networks - trusted
└── policies/
    ├── zerotier-to-lan.xml   # Forward: ZeroTier → LAN/Internet
    └── lan-to-zerotier.xml   # Forward: LAN → ZeroTier (return traffic)

~/.config/docker-firewall/
├── README.md              # Docker firewall docs
├── rules.conf             # DOCKER-USER rules config
├── apply-rules.sh         # Apply iptables rules
└── docker-firewall.service # Systemd service
```

## Zone Configuration

| Zone | Interface | Purpose |
|------|-----------|---------|
| `zerotier` | `ztyjkjucbr` | Services allowed, forwarding enabled |
| `public` | `enp9s0` | Restrictive, NAT enabled, stealth mode |
| `docker` | `docker0`, `br-*` | Trusted for Docker traffic |

## Allowed Ports (ZeroTier Zone)

| Port | Protocol | Service |
|------|----------|---------|
| 22 | tcp | SSH |
| 3000 | tcp | OpenWebUI |
| 3001 | tcp | Webpage server |
| 11434 | tcp | Ollama |
| 1883 | tcp | MQTT Broker |
| 4533 | tcp | Navidrome |
| 9993 | udp | ZeroTier |
| 27036 | tcp/udp | Steam Remote Play |

## Security Features

### 1. Service Protection
- Services only accessible from ZeroTier network
- External LAN (10.95.12.0/24) blocked from services

### 2. Docker Protection (DOCKER-USER)
- Docker containers protected via iptables DOCKER-USER chain
- Allows: ZeroTier (`zt+`), localhost, Docker networks
- Blocks: External interface (`enp9s0`)

### 3. Stealth Mode
- Ping requests are silently dropped (no response)
- Machine appears invisible to network scans
- You can still ping others

### 4. ZeroTier Gateway
- Forward traffic from ZeroTier to LAN and internet
- NAT/Masquerade enabled on public zone

## Modify Configuration

### Add a port to ZeroTier zone
Edit `~/.config/firewalld/zones/zerotier.xml`:
```xml
<port port="8080" protocol="tcp"/>
```
Then apply:
```bash
~/.config/firewalld/update.sh
```

### Add/remove ICMP stealth
```bash
# Enable stealth (drop ping)
sudo firewall-cmd --zone=public --add-rich-rule='rule icmp-type name="echo-request" drop' --permanent

# Disable stealth (respond to ping)
sudo firewall-cmd --zone=public --remove-rich-rule='rule icmp-type name="echo-request" drop' --permanent

sudo firewall-cmd --reload
```

### Modify Docker firewall rules
Edit `~/.config/docker-firewall/rules.conf`:
```conf
ALLOW_INTERFACE=zt+
ALLOW_INTERFACE=lo
ALLOW_INTERFACE=docker0
ALLOW_INTERFACE=br-+
BLOCK_INTERFACE=enp9s0
```
Then apply:
```bash
sudo systemctl restart docker-firewall
```

## ZeroTier Gateway Setup

This machine acts as a gateway for remote ZeroTier devices.

### Managed Routes (my.zerotier.com)

| Destination | Via (this machine's ZT IP) |
|-------------|----------------------------|
| `10.95.12.0/24` | `<your-zt-ip>` |
| `0.0.0.0/0` | `<your-zt-ip>` | *(optional - full internet)* |

### Remote device requirements
- Enable "Allow Default Route" in ZeroTier client (for 0.0.0.0/0)
- Target LAN devices must allow connections from ZeroTier subnet

## Services on Boot

| Service | Auto-start |
|---------|------------|
| firewalld | ✅ Enabled |
| docker-firewall | ✅ Enabled |
| docker | ✅ Enabled |
| → ollama | ✅ Auto-start |
| → open-webui | ✅ Auto-start |
| → navidrome | ✅ Auto-start |

## Troubleshooting

### Check status
```bash
~/.config/firewalld/check.sh
```

### View firewall rules
```bash
sudo firewall-cmd --zone=public --list-all
sudo firewall-cmd --zone=zerotier --list-all
sudo iptables -L DOCKER-USER -v -n
```

### View logs
```bash
sudo journalctl -u firewalld -n 50
sudo journalctl -u docker-firewall -n 50
```

### Restart services
```bash
sudo systemctl restart firewalld
sudo systemctl restart docker-firewall
```

## Emergency - Disable Everything

```bash
# Stop firewalls
sudo systemctl stop firewalld
sudo systemctl stop docker-firewall
sudo iptables -F DOCKER-USER && sudo iptables -A DOCKER-USER -j RETURN

# Disable on boot
sudo systemctl disable firewalld
sudo systemctl disable docker-firewall
```

## Full Setup (Recreate from Scratch)

If you need to recreate this entire setup on a new system:

### 1. Install firewalld (if not installed)
```bash
sudo dnf install firewalld
sudo systemctl enable --now firewalld
```

### 2. Copy zone and policy files
```bash
# Zones
sudo cp ~/.config/firewalld/zones/*.xml /etc/firewalld/zones/

# Policies
sudo mkdir -p /etc/firewalld/policies
sudo cp ~/.config/firewalld/policies/*.xml /etc/firewalld/policies/

# Reload
sudo firewall-cmd --reload
```

### 3. Install Docker firewall service
```bash
sudo cp ~/.config/docker-firewall/docker-firewall.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now docker-firewall
```

### 5. Enable SELinux boolean for containers
```bash
sudo setsebool -P container_use_execmem on
```

### 6. Verify everything
```bash
~/.config/firewalld/check.sh
```

### All-in-one script
```bash
# Full setup in one go
sudo dnf install -y firewalld
sudo systemctl enable --now firewalld
sudo cp ~/.config/firewalld/zones/*.xml /etc/firewalld/zones/
sudo mkdir -p /etc/firewalld/policies
sudo cp ~/.config/firewalld/policies/*.xml /etc/firewalld/policies/
sudo firewall-cmd --reload
sudo cp ~/.config/docker-firewall/docker-firewall.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now docker-firewall
sudo setsebool -P container_use_execmem on
~/.config/firewalld/check.sh
```

Note: Stealth mode (drop ping) is already included in `public.xml`.

## Files Location

| Location | Purpose |
|----------|---------|
| `~/.config/firewalld/` | Your config (source of truth) |
| `~/.config/docker-firewall/` | Docker firewall config |
| `/etc/firewalld/zones/` | Active zone configs |
| `/etc/firewalld/policies/` | Active policy configs |
| `/etc/systemd/system/docker-firewall.service` | Docker firewall service |
