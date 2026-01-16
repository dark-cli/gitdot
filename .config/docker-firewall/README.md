# Docker Firewall (DOCKER-USER chain)

Restricts Docker container access by network interface. Blocks LAN access while allowing ZeroTier VPN.

## Why This Exists

Docker bypasses firewalld entirely - it manipulates iptables directly. Even if firewalld blocks a port, Docker containers remain accessible. The only way to filter Docker traffic is through the `DOCKER-USER` iptables chain, which Docker processes BEFORE its own NAT rules.

## Files

| File | Purpose |
|------|---------|
| `rules.conf` | Configuration - which interfaces to allow/block |
| `apply-rules.sh` | Script that reads config and applies iptables rules |
| `docker-firewall.service` | Systemd service to apply rules on boot and after Docker restarts |

## Installation

```bash
# Install the systemd service
sudo cp ~/.config/docker-firewall/docker-firewall.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now docker-firewall
```

## Updating

After modifying any files, reinstall the service:

```bash
sudo cp ~/.config/docker-firewall/docker-firewall.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart docker-firewall
```

## Usage

### Apply rules now
```bash
sudo ~/.config/docker-firewall/apply-rules.sh
```

### View current rules
```bash
sudo iptables -L DOCKER-USER -v --line-numbers
```

### Modify rules
Edit `~/.config/docker-firewall/rules.conf`, then:
```bash
sudo systemctl restart docker-firewall
```

## Configuration (rules.conf)

```conf
# Allow traffic from an interface
ALLOW_INTERFACE=zt+        # ZeroTier (zt+ matches any zt* interface)
ALLOW_INTERFACE=lo         # Localhost
ALLOW_INTERFACE=docker0    # Docker bridge
ALLOW_INTERFACE=br-+       # Docker compose networks

# Block traffic from an interface
BLOCK_INTERFACE=enp9s0     # External/LAN interface
```

## Current Setup

| Interface | Access to Docker |
|-----------|------------------|
| `zt+` (ZeroTier) | ✅ Allowed |
| `lo` (localhost) | ✅ Allowed |
| `docker0`, `br-+` | ✅ Allowed |
| `enp9s0` (LAN) | ❌ Blocked |

## Troubleshooting

### Rules not applied after reboot
```bash
sudo systemctl status docker-firewall
sudo journalctl -u docker-firewall
```

### Rules disappeared after Docker restart
The service uses `PartOf=docker.service` to automatically restart when Docker restarts. If rules are missing:

```bash
sudo systemctl restart docker-firewall
sudo iptables -L DOCKER-USER -v -n --line-numbers
```

Verify the service file has `PartOf=docker.service` in the `[Unit]` section.

### Verify blocking is working
From a LAN device, try to access a Docker container port. Then check if the DROP rule counter increased:

```bash
sudo iptables -L DOCKER-USER -v -n --line-numbers
# Look for packets hitting the DROP rule for enp9s0
```

### Temporarily disable
```bash
sudo systemctl stop docker-firewall
sudo iptables -F DOCKER-USER
sudo iptables -A DOCKER-USER -j RETURN
```

### Re-enable
```bash
sudo systemctl start docker-firewall
```
