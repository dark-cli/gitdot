-- System Keybinds (145 total)
-- Window control, workspace navigation, audio, brightness, etc.
-- Ported from: configs/Keybinds.conf

local HOME = os.getenv("HOME")
local SCRIPTS = HOME .. "/.config/hypr/scripts"
local USER_SCRIPTS = HOME .. "/.config/hypr/UserScripts"
local TERM = "kitty"
local FILES = "nautilus"

-- ============================================
-- STANDARD / COMMON SHORTCUTS
-- ============================================

-- Application launchers
hl.bind("SUPER + D", hl.dsp.exec_cmd(SCRIPTS .. "/Launcher.sh")) --: app launcher (apps, /dirs, >cmds, !power; F1 help)
hl.bind("SUPER + B", hl.dsp.exec_cmd("xdg-open 'https://'")) --: open default browser
hl.bind("SUPER + A", hl.dsp.exec_cmd(SCRIPTS .. "/OverviewToggle.sh")) --: desktop overview
hl.bind("SUPER + Return", hl.dsp.exec_cmd(TERM)) --: open terminal
hl.bind("SUPER + E", hl.dsp.exec_cmd(SCRIPTS .. "/YaziLaunch.sh")) --: file browser (yazi)

-- Features / Extras
hl.bind("SUPER + T", hl.dsp.exec_cmd(SCRIPTS .. "/ThemeChangerLaunch.sh")) --: theme switcher (wallust, fzf)
hl.bind("SUPER + F1", hl.dsp.exec_cmd(SCRIPTS .. "/KeyHints.sh")) --: help / cheat sheet
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(SCRIPTS .. "/Refresh.sh")) --: refresh bar and menus
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd(SCRIPTS .. "/EmojiPickerLaunch.sh")) --: emoji picker (fzf)
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd(SCRIPTS .. "/WindowSwitcherLaunch.sh")) --: window switcher (fzf)
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(SCRIPTS .. "/ChangeBlur.sh")) --: toggle blur
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd(SCRIPTS .. "/GameMode.sh")) --: toggle game mode
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd(SCRIPTS .. "/ChangeLayout.sh")) --: toggle master/dwindle layout
hl.bind("SUPER + V", hl.dsp.exec_cmd(SCRIPTS .. "/ClipMenuLaunch.sh")) --: clipboard picker (fzf)

-- Window state & floating
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen()) --: toggle fullscreen
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ all = true })) --: maximize window
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" })) --: toggle floating
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.center({ respect_reserved = true })) --: center floating window on screen
hl.bind("SUPER + ALT + Space", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat")) --: float all windows on workspace
hl.bind("SUPER + SHIFT + Return", require("lua.helpers.dropdown").toggle) --: toggle dropdown terminal

-- Desktop zoom (magnifier)
hl.bind("SUPER + ALT + mouse_down", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')\"")) --: zoom in (desktop magnifier)
hl.bind("SUPER + ALT + mouse_up", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')\"")) --: zoom out (desktop magnifier)

-- Waybar / Bar related
hl.bind("SUPER + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar")) --: toggle waybar on/off
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd(SCRIPTS .. "/WaybarStylesLaunch.sh")) --: waybar styles menu (fzf)
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd(SCRIPTS .. "/WaybarLayoutLaunch.sh")) --: waybar layout menu (fzf)

-- Night light
hl.bind("SUPER + N", hl.dsp.exec_cmd(SCRIPTS .. "/Hyprsunset.sh toggle")) --: toggle night light (hyprsunset)

-- User Scripts
hl.bind("SUPER + W", hl.dsp.exec_cmd(SCRIPTS .. "/WallpaperPickerFzf.sh")) --: wallpaper picker (gallery)
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(SCRIPTS .. "/WallpaperEffectsLaunch.sh")) --: wallpaper effects (fzf)
hl.bind("CTRL + ALT + W", hl.dsp.exec_cmd(USER_SCRIPTS .. "/WallpaperRandom.sh")) --: random wallpaper
hl.bind("SUPER + CTRL + O", hl.dsp.exec_cmd("hyprctl setprop active opaque toggle")) --: toggle window opacity
hl.bind("SUPER + F2", hl.dsp.exec_cmd(SCRIPTS .. "/KeyBinds.sh")) --: search keybinds
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(SCRIPTS .. "/AnimationsLaunch.sh")) --: animations menu (fzf)
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd(SCRIPTS .. "/ZshChangeThemeLaunch.sh")) --: change zsh theme (fzf)

-- Move workspaces to monitors
hl.bind("SUPER + CTRL + F9", hl.dsp.workspace.move({ monitor = "l" })) --: move workspace to left monitor
hl.bind("SUPER + CTRL + F10", hl.dsp.workspace.move({ monitor = "r" })) --: move workspace to right monitor
hl.bind("SUPER + CTRL + F11", hl.dsp.workspace.move({ monitor = "u" })) --: move workspace to up monitor
hl.bind("SUPER + CTRL + F12", hl.dsp.workspace.move({ monitor = "d" })) --: move workspace to down monitor

-- ============================================
-- SYSTEM KEYBINDS
-- ============================================

hl.bind("CTRL + ALT + Delete", hl.dsp.exit(), { locked = true }) --: exit Hyprland session
hl.bind("SUPER + Q", hl.dsp.window.close()) --: close active window
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd(SCRIPTS .. "/KillActiveProcess.sh")) --: kill active process
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(SCRIPTS .. "/LockScreen.sh")) --: lock screen
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(SCRIPTS .. "/WlogoutLaunch.sh")) --: power menu (fzf)
-- Blank the screens (DPMS off). misc.mouse_move_enables_dpms and
-- misc.key_press_enables_dpms in lua/core/config.lua wake them back
-- up on the next mouse move or key press. No lock — this is just a
-- screen-off, matching the "Blank screen" entry in the ! power menu.
-- Goes through BlankScreen.sh which sleeps briefly first, otherwise
-- the trigger key's release event would wake the display immediately.
hl.bind("CTRL + ALT + Home", hl.dsp.exec_cmd(SCRIPTS .. "/BlankScreen.sh"), { locked = true }) --: blank screens (wakes on mouse/key)
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw")) --: toggle notification panel
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd(SCRIPTS .. "/Kool_Quick_SettingsLaunch.sh")) --: edit config / Kool Quick Settings menu (fzf)

-- ============================================
-- MASTER LAYOUT
-- ============================================

hl.bind("SUPER + CTRL + D", hl.dsp.layout("removemaster")) --: remove master (master layout)
hl.bind("SUPER + I", hl.dsp.layout("addmaster")) --: add master (master layout)
hl.bind("SUPER + CTRL + Return", hl.dsp.layout("swapwithmaster")) --: swap with master (master layout)

-- ============================================
-- DWINDLE LAYOUT
-- ============================================

hl.bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit")) --: toggle split (dwindle layout)
hl.bind("SUPER + P", hl.dsp.window.pseudo()) --: toggle pseudo (dwindle layout)

-- ============================================
-- LAYOUT MANAGEMENT
-- ============================================

hl.bind("SUPER + M", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3")) --: set split ratio to 0.3

-- ============================================
-- WINDOW CYCLING
-- ============================================

-- If the focused window is fullscreen, fullscreen moves to the next window
-- instantly (Hyprland 0.51 behaviour); see helpers/fullscreen_cycle.lua
hl.bind("ALT + Tab", require("lua.helpers.fullscreen_cycle").cycle) --: cycle to next window

-- ============================================
-- SPECIAL KEYS / HOT KEYS (Audio, Media, etc.)
-- ============================================

-- Volume control. Direct wpctl on the hot path so the volume change is
-- instant; the notification is fired off the critical path via sh -c
-- backgrounding. `repeating` auto-fires while held; `locked` keeps these
-- working on the lockscreen.
local vol_opts = { repeating = true, locked = true }
local NOTIFY = SCRIPTS .. "/VolumeNotify.sh"
hl.bind("XF86AudioRaiseVolume",        hl.dsp.exec_cmd("sh -c 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && " .. NOTIFY .. " &'"), vol_opts) --: volume up
hl.bind("XF86AudioLowerVolume",        hl.dsp.exec_cmd("sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " .. NOTIFY .. " &'"), vol_opts) --: volume down
hl.bind("ALT + XF86AudioRaiseVolume",  hl.dsp.exec_cmd("sh -c 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+ && " .. NOTIFY .. " &'"), vol_opts) --: volume up (precise)
hl.bind("ALT + XF86AudioLowerVolume",  hl.dsp.exec_cmd("sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%- && " .. NOTIFY .. " &'"), vol_opts) --: volume down (precise)
hl.bind("XF86AudioMicMute",            hl.dsp.exec_cmd("sh -c 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && " .. NOTIFY .. " mic &'"), { locked = true }) --: toggle microphone mute
hl.bind("XF86AudioMute",               hl.dsp.exec_cmd("sh -c 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " .. NOTIFY .. " &'"), { locked = true }) --: toggle audio mute

-- System controls — `locked = true` keeps these working on the lockscreen.
hl.bind("XF86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true }) --: suspend system
hl.bind("XF86Rfkill", hl.dsp.exec_cmd(SCRIPTS .. "/AirplaneMode.sh"), { locked = true }) --: toggle airplane mode

-- Media controls (XF86AudioPlayPause is not a valid keysym - use XF86AudioPause/Play instead).
-- All flagged `locked` so play/pause/skip work while hyprlock is up.
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --pause"), { locked = true }) --: media pause/resume
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --pause"), { locked = true }) --: media play/pause
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --nxt"),   { locked = true }) --: media next track
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --prv"),   { locked = true }) --: media previous track
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd(SCRIPTS .. "/MediaCtrl.sh --stop"),  { locked = true }) --: media stop

-- ============================================
-- SCREENSHOT KEYBINDINGS
-- ============================================

hl.bind("SUPER + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --now")) --: screenshot (full screen)
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --area")) --: screenshot (select area)
hl.bind("SUPER + CTRL + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --in5")) --: screenshot in 5 seconds
hl.bind("SUPER + CTRL + SHIFT + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --in10")) --: screenshot in 10 seconds
hl.bind("ALT + Print", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --active")) --: screenshot of active window
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(SCRIPTS .. "/ScreenShot.sh --swappy")) --: screenshot with swappy editor

-- ============================================
-- WINDOW RESIZE (Hold to repeat)
-- ============================================

hl.bind("SUPER + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true }) --: resize window left (-50px)
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true }) --: resize window right (+50px)
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true }) --: resize window up (-50px)
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true }) --: resize window down (+50px)

-- ============================================
-- WINDOW MOVEMENT
-- ============================================

hl.bind("SUPER + CTRL + Left", hl.dsp.window.move({ direction = "l" })) --: move window left
hl.bind("SUPER + CTRL + Right", hl.dsp.window.move({ direction = "r" })) --: move window right
hl.bind("SUPER + CTRL + Up", hl.dsp.window.move({ direction = "u" })) --: move window up
hl.bind("SUPER + CTRL + Down", hl.dsp.window.move({ direction = "d" })) --: move window down

-- ============================================
-- WINDOW SWAPPING
-- ============================================

hl.bind("SUPER + ALT + Left", hl.dsp.window.swap({ direction = "l" })) --: swap window with left neighbor
hl.bind("SUPER + ALT + Right", hl.dsp.window.swap({ direction = "r" })) --: swap window with right neighbor
hl.bind("SUPER + ALT + Up", hl.dsp.window.swap({ direction = "u" })) --: swap window with above neighbor
hl.bind("SUPER + ALT + Down", hl.dsp.window.swap({ direction = "d" })) --: swap window with below neighbor

-- ============================================
-- GROUP MANAGEMENT
-- ============================================

hl.bind("SUPER + G", hl.dsp.group.toggle()) --: toggle window grouping
hl.bind("SUPER + Tab", hl.dsp.group.next()) --: cycle to next group member
hl.bind("SUPER + CTRL + Tab", hl.dsp.group.next()) --: cycle to next group member
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev()) --: cycle to previous group member

-- Move windows into/out of groups (reassigned from SUPER+CTRL+H/K/L to avoid vim-style resize conflict)
hl.bind("SUPER + F3", hl.dsp.group.move_window({ direction = "l" })) --: move window into group on left
hl.bind("SUPER + F4", hl.dsp.group.move_window({ direction = "r" })) --: move window into group on right
hl.bind("SUPER + F5", hl.dsp.exec_cmd("hyprctl dispatch moveoutofgroup")) --: move window out of group

-- ============================================
-- WINDOW FOCUS
-- ============================================

hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" })) --: focus window left
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" })) --: focus window right
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" })) --: focus window up
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" })) --: focus window down

-- ============================================
-- WORKSPACE NAVIGATION
-- ============================================

hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" })) --: next workspace
hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" })) --: previous workspace

-- Special workspace
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "special" })) --: move window to special workspace
hl.bind("SUPER + U", hl.dsp.workspace.toggle_special()) --: toggle special workspace

-- ============================================
-- WORKSPACE SWITCHING (By Number)
-- ============================================

-- Switch to workspace with Super + [1-9, 0]
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local code = i < 10 and "code:" .. (9 + i) or "code:19"
  hl.bind("SUPER + " .. code, hl.dsp.focus({ workspace = i })) --: switch to workspace N (1-9, 0)
end

-- ============================================
-- MOVE WINDOW TO WORKSPACE
-- ============================================

-- Move window to workspace with Super + Shift + [1-9, 0]
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local code = i < 10 and "code:" .. (9 + i) or "code:19"
  hl.bind("SUPER + SHIFT + " .. code, hl.dsp.window.move({ workspace = i })) --: move window to workspace N (1-9, 0)
end

hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "e-1" })) --: move window to previous workspace
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ workspace = "e+1" })) --: move window to next workspace

-- ============================================
-- MOVE WINDOW SILENTLY TO WORKSPACE
-- ============================================

-- Move window silently with Super + Ctrl + [1-9, 0]
-- The Lua field is `follow` (per the Hyprland source in
-- LuaBindingsDispatchers.cpp: `silent = follow.has_value() && !*follow`),
-- NOT `silent`. `follow = false` maps to the legacy `movetoworkspacesilent`
-- dispatcher — the window moves and focus stays put.
for i = 1, 10 do
  local key = i == 10 and "0" or tostring(i)
  local code = i < 10 and "code:" .. (9 + i) or "code:19"
  hl.bind("SUPER + CTRL + " .. code, hl.dsp.window.move({ workspace = i, follow = false })) --: throw window to workspace N (1-9, 0) without switching
end

hl.bind("SUPER + CTRL + bracketleft", hl.dsp.window.move({ workspace = "e-1", follow = false })) --: throw window to previous workspace without switching
hl.bind("SUPER + CTRL + bracketright", hl.dsp.window.move({ workspace = "e+1", follow = false })) --: throw window to next workspace without switching

-- ============================================
-- SCROLL THROUGH WORKSPACES
-- ============================================

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" })) --: next workspace (scroll)
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" })) --: previous workspace (scroll)
hl.bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" })) --: next workspace
hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" })) --: previous workspace

-- ============================================
-- MOUSE BINDINGS
-- ============================================

-- LMB: Move window, RMB: Resize window
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true }) --: drag window with mouse (LMB)
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true }) --: resize window with mouse (RMB)

-- All system keybinds loaded
