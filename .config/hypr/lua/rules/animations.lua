-- Animation Configuration
-- Uses Hyprland's default styles with fast speeds
-- Note: Hyprland "speed" is actually duration in units of 100ms (LOWER = faster)

local ANIMATIONS = {
  { leaf = "global",           enabled = true, speed = 3,   bezier = "default" },
  { leaf = "windows",          enabled = true, speed = 2,   bezier = "default" },
  { leaf = "windowsIn",        enabled = true, speed = 2,   bezier = "default" },
  { leaf = "windowsOut",       enabled = true, speed = 1.5, bezier = "default" },
  { leaf = "windowsMove",      enabled = true, speed = 2,   bezier = "default" },
  { leaf = "border",           enabled = true, speed = 3,   bezier = "default" },
  { leaf = "fade",             enabled = true, speed = 2,   bezier = "default" },
  { leaf = "fadeIn",           enabled = true, speed = 2,   bezier = "default" },
  { leaf = "fadeOut",          enabled = true, speed = 1.5, bezier = "default" },
  { leaf = "workspaces",       enabled = true, speed = 2.5, bezier = "default" },
  -- specialWorkspace animation disabled: eliminates the dark shade flash when
  -- the dropdown terminal is moved into/out of special:scratchpad
  { leaf = "specialWorkspace", enabled = false, bezier = "default" },
}

for _, spec in ipairs(ANIMATIONS) do
  hl.animation(spec)
end

-- Returned so helpers can briefly disable a leaf and restore it exactly
-- (see helpers/fullscreen_cycle.lua)
return ANIMATIONS
