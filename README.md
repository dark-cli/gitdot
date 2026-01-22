# gitdot

Personal Linux dotfiles, managed with [lazydot](https://github.com/nickspaargaren/lazydot). Hyprland-based setup with Waybar, Wallust, firewalld, and assorted app configs.

---

## Synced paths (lazydot)

| Path | Description |
|------|-------------|
| `~/.config/alacritty` | Terminal (Alacritty) |
| `~/.config/hypr` | Hyprland compositor, scripts, monitor profiles |
| `~/.config/nvim` | Neovim (NvChad-based) |
| `~/.config/waybar` | Waybar configs, layouts, styles |
| `~/.config/lazydot.toml` | Lazydot config |
| `~/.config/firewalld` | Firewalld zones and policies |
| `~/.config/docker-firewall` | Docker DOCKER-USER rules (blocks LAN, allows ZeroTier) |
| `~/.p10k.zsh` | Powerlevel10k (Zsh) |
| `~/.icons` | Icon set |
| `~/.tmux.conf` | Tmux |
| `~/.local/share/winbox` | WinBox (MikroTik) assets |
| `~/.local/open-webui` | OpenWebUI docker-compose |

---

## Hyprland

- **Base:** Fork of [JaKooLit/Hyprland-v3](https://github.com/JaKooLit/Hyprland-v3), migrated from v2.3.13 to v2.3.18, then updated for v0.51.0.
- **User configs:** `UserConfigs/` and `UserScripts/` override defaults (keybinds, startup, window rules, workspace rules).

### Keybinds (custom)

| Keys | Action |
|------|--------|
| `Super` + `h/j/k/l` | Vim-style focus (left/down/up/right) |
| `Super` + `Shift` + `h/j/k/l` | Move window |
| `Super` + `Ctrl` + `h/j/k/l` | Resize window |
| `Super` + `=/+/-` | Increase / decrease gaps; `Super` + `BackSpace` reset |
| `Super` + `Shift` + `Return` | Dropdown terminal (pyprland) |
| `Super` + `Z` | Desktop zoom (pyprland) |
| `Super` + `O` | Search keybinds (rofi) |
| `Super` + `Shift` + `B` | Reset Waybar |
| `Super` + `W` | Wallpaper selector |
| `Ctrl` + `Alt` + `Home` | Suspend |
| `Alt` + `Shift` | Switch keyboard layout |

### Pyprland

- **Dropdown terminal:** `Super` + `Shift` + `Return` → Alacritty (`alacritty-dropterm`), 65% size, from-top.
- **Zoom:** `Super` + `Z` for desktop zoom/magnify.

### Monitor & tablet

- **Monitor profiles:** `Monitor_Profiles/` (e.g. `default`, `default_90`, `default_270`); switch via Rofi (e.g. Quick Settings).
- **Tablet rotation:** `SyncTabletTransform.sh` runs at startup and sets `input:tablet:transform` from `monitors.conf` (90° or 270° profile → tablet 90°; else 0°).
- **History:** 90° and 270° display profiles, automatic tablet sync with 270° profile, 90° clockwise drawing tablet.

### Wallpaper & lock

- **Wallpaper:** swww; `WallpaperSelect.sh`, `WallpaperRandom.sh`, `WallpaperAutoChange.sh`, `WallpaperEffects.sh` (Rofi).
- **Hyprlock:** Uses `~/.config/hypr/wallpaper_effects/.wallpaper_current` (same as desktop); all wallpaper scripts and `DarkLight.sh` keep it in sync.
- **Hypridle:** Pre-lock step copies current swww image into `.wallpaper_current` so hyprlock matches the desktop.

### Scripts (high level)

- **Rofi:** App launcher, emoji, search, theme selector, keybinds, animations, clipboard, calc.
- **Waybar:** Layout selector, style selector, Refresh, RefreshNoWaybar.
- **System:** Brightness, volume, screenshots, lock, polkit, gamemode, battery, airplane mode.
- **Other:** `WallustSwww.sh`, `DarkLight.sh`, `sddm_wallpaper.sh`, `Kool_Quick_Settings.sh`, `MonitorProfiles.sh`, etc.

### User scripts

- `RainbowBorders.sh` – Rainbow borders.
- `RofiBeats.sh` – Music/rofi.
- `RofiCalc.sh` – Calculator (qalculate + rofi).
- `WallpaperSelect.sh` / `WallpaperRandom.sh` / `WallpaperAutoChange.sh` / `WallpaperEffects.sh` – Wallpapers.
- `Weather.sh` / `WeatherWrap.sh` / `Weather.py` – Weather.
- `ZshChangeTheme.sh` – Zsh theme switcher.

---

## Waybar

- **Config layout:** `config` → `configs/<layout>`; `style.css` → `style/<theme>.css`.
- **Layouts:** TOP/BOT/LEFT/RIGHT and combined (e.g. SummitSplit, NorthWest, SouthWest, EastWing, WestWing, Camellia, Chrysanthemum, Gardenia, Peony, Simple, Sleek, Default, Everforest, Minimal, Arrow, 0-Ja-0, etc.).
- **Styles:** 40+ themes: Catppuccin (Mocha, Latte, Frappe), Wallust (Chroma, Simple, Transparent, Bordered, ML4W), Dark (Purpl, Golden Noir/Eclipse, Half-Moon, Obsidian Edge), Colored, Extra (Mauve, Rose Pine, EverForest, Crimson, Arrow, etc.), [Max Wallust] Crystal Clear & Simple, [Transparent] Crystal Clear, [Retro] Simple, and more.
- **Wallust:** `wallust/colors-waybar.css`; [Transparent] Crystal Clear and [Max Wallust] styles use Wallust.
- **Font:** 99% font-size across themes; JetBrainsMono Nerd Font.
- **Workspace icons:** `hyprland/workspaces#rw` with `window-rewrite` for many apps: browsers (Firefox, Chrome, Edge, Brave, Tor, etc.), terminals (Alacritty, Kitty, WezTerm, Ghostty), mail, chat, media (Spotify, Cider, mpv, VLC, YouTube), dev (VS Code, Cursor, nvim, JetBrains, Obsidian), system (WinBox, Bottles, Thunar, GIMP, Steam, virt-manager, Feishin), and more. Kitry/Alacritty use U+F489.
- **Modules:** `Modules`, `ModulesCustom`, `ModulesGroups`, `ModulesVertical`, `ModulesWorkspaces`, `UserModules` (e.g. cava, playerctl, weather, app/mobo/notify/audio/status drawers).
- **Doc:** `alacritty-icon-options.md` – notes on terminal icons for Waybar.

---

## Security & networking

### Firewalld

- **Zones:** `zerotier` (services), `public` (restrictive + NAT), `docker`.
- **Behavior:** Services (SSH, OpenWebUI, Ollama, Navidrome, MQTT, etc.) allowed on ZeroTier + localhost; external LAN blocked; stealth (drop ping); ZeroTier gateway for LAN/internet.
- **Files:** `zones/` (zerotier, public, docker), `policies/` (zerotier-to-lan, lan-to-zerotier), `check.sh`, `update.sh`.
- **Docs:** `~/.config/firewalld/README.md`.

### Docker firewall

- **DOCKER-USER:** Restricts Docker by interface; LAN (`enp9s0`) blocked; ZeroTier (`zt+`), `lo`, `docker0`, `br-+` allowed.
- **Files:** `rules.conf`, `apply-rules.sh`, `docker-firewall.service` (systemd, `PartOf=docker.service`).
- **Docs:** `~/.config/docker-firewall/README.md`.

### Ports (ZeroTier zone)

- 22 (SSH), 3000 (OpenWebUI), 3001 (webpage), 8000 (Debts manager app), 11434 (Ollama), 1883 (MQTT), 4533 (Navidrome), 9993 (ZeroTier), 27036 (Steam Remote Play).

---

## Apps & integrations

### Startup / automation

- **Feishin** (Navidrome client) – `exec-once` in `Startup_Apps.conf`.
- **Pyprland** – `exec-once` for dropdown + zoom.
- **SyncTabletTransform.sh** – tablet/monitor sync at login.
- **Firefox** and optional Discord/Spotify, etc.

### Docker

- **OpenWebUI:** `~/.local/open-webui/docker-compose.yaml` – Ollama + OpenWebUI (NVIDIA runtime); OpenWebUI on 3000, Ollama 11434.
- **Firewalld:** OpenWebUI, Ollama, Navidrome, port 3001, etc. on ZeroTier.

### Other

- **WinBox** (MikroTik) – `~/.local/share/winbox`; Waybar icon in `ModulesWorkspaces`.
- **Feishin** – Workspace 10, Waybar icon.
- **Break reminder:** `BreakReminder.sh` was added (then removed/disabled; originally “waiting for better API”).

---

## Neovim

- **Base:** [NvChad](https://github.com/NvChad/NvChad) as a plugin; this repo provides the config.
- **Config:** `lua/` (chadrc, options, mappings, configs, plugins); Lazy, LSP, Conform, etc.

---

## Other

- **Alacritty** – `~/.config/alacritty/alacritty.toml`.
- **Zsh** – `~/.zshrc`, Powerlevel10k `~/.p10k.zsh`; fzf for path search.
- **Tmux** – `~/.tmux.conf`.
- **Icons** – `~/.icons` (large set).
- **Lazydot** – `~/.config/lazydot.toml`; `current_state.toml` for state.

---

## Summary of changes (from git history)

- **First / early:** lazydot, nvim (NvChad), hypr monitors, .zshrc, fzf path search, icons.
- **Hyprland:** v0.51.0 update; 90° and 270° monitor profiles; tablet 90° rotation; `SyncTabletTransform` for tablet/monitor; pyprland (dropdown + zoom).
- **Security:** firewalld (ZeroTier, stealth, gateway); docker-firewall (DOCKER-USER); docker-firewall + port 3001 over ZeroTier.
- **Apps:** Feishin, WinBox, BreakReminder (added, later removed/disabled); OpenWebUI docker-compose; lazydot paths for firewalld, docker-firewall, winbox, open-webui.
- **Hyprland config:** Migration to v2.3.18; UserConfigs/UserScripts; fix double waybar from duplicate startup.
- **Wallpaper / lock:** All wallpaper scripts and DarkLight write to `.wallpaper_current`; hyprlock and hypridle use it; pre-lock sync in hypridle.
- **Waybar:** Full waybar layout and style set; font 99%; Wallust in [Transparent] and [Max Wallust] Crystal Clear; U+F489 for Kitty/Alacritty; [Max Wallust] themes; `alacritty-icon-options.md`; navidrome cache removed from repo.
- **Misc:** Hyprland wallust config; waybar icons for new apps (e.g. Feishin, WinBox, Bottles, Cider, Obsidian, ParaView, xournal++, HTTP Toolkit).

---

## Credits

- [JaKooLit/Hyprland-v3](https://github.com/JaKooLit/Hyprland-v3) – Hyprland base.
- [NvChad](https://github.com/NvChad/NvChad) – Neovim base.
- [lazydot](https://github.com/nickspaargaren/lazydot) – Dotfile management.
