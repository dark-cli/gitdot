-- Startup Apps & Services
-- Boot sequence for Hyprland initialization
-- Ported from: Startup_Apps.conf (configs + UserConfigs)

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local USER_SCRIPTS = HOME .. "/.config/hypr/UserScripts"

hl.on("hyprland.start", function()
  -- ============================================
  -- CORE DAEMONS (must start first)
  -- ============================================

  -- Wallpaper daemon
  hl.exec_cmd("swww-daemon --format xrgb")

  -- Environment setup
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

  -- ============================================
  -- INITIALIZATION SERVICES
  -- ============================================

  -- Desktop portal (enables screen sharing/recording for Discord, OBS, etc)
  hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
  hl.exec_cmd("systemctl --user start xdg-desktop-portal")

  -- Keyboard layout initialization
  hl.exec_cmd(SCRIPTS .. "/KeybindsLayoutInit.sh")

  -- Dropdown terminal: start it hidden in the scratchpad (helpers/dropdown.lua)
  require("lua.helpers.dropdown").spawn(true)

  -- ============================================
  -- AUTHENTICATION & SYSTEM
  -- ============================================

  -- Polkit authentication agent
  hl.exec_cmd(SCRIPTS .. "/Polkit.sh")

  -- Network manager applet
  hl.exec_cmd("nm-applet --indicator")

  -- ============================================
  -- UI COMPONENTS
  -- ============================================

  -- Notification daemon
  hl.exec_cmd("swaync")

  -- Status bar
  hl.exec_cmd("waybar")

  -- Quickshell overview (optional, comment out if not needed)
  hl.exec_cmd("qs -c overview")

  -- ============================================
  -- CLIPBOARD MANAGEMENT
  -- ============================================

  -- Clipboard manager (text and images)
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- ============================================
  -- VISUAL EFFECTS
  -- ============================================

  -- Rainbow window borders
  hl.exec_cmd(USER_SCRIPTS .. "/RainbowBorders.sh")

  -- ============================================
  -- SYSTEM DAEMONS
  -- ============================================

  -- Idle/lock daemon
  hl.exec_cmd("hypridle")

  -- Night light (resume from previous session state)
  hl.exec_cmd(SCRIPTS .. "/Hyprsunset.sh init")

  -- ============================================
  -- OPTIONAL USER APPLICATIONS
  -- ============================================

  -- Zen browser (to workspace 1)
  hl.exec_cmd("hyprctl dispatch workspace 1 && zen &")

  -- Discord (to workspace 1) - uncomment to auto-launch
  -- hl.exec_cmd("hyprctl dispatch workspace 1 && discord &")

  -- Telegram (to workspace 1) - uncomment to auto-launch
  -- hl.exec_cmd("hyprctl dispatch workspace 1 && telegram-desktop &")

  -- Feishin music player (Navidrome client)
  hl.exec_cmd(HOME .. "/.local/share/feishin/Feishin.AppImage --no-sandbox &")

  -- Uncomment below to auto-launch on startup
  -- hl.exec_cmd("discord &")
  -- hl.exec_cmd("flatpak run com.spotify.Client &")
end)
