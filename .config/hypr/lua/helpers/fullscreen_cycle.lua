-- Fullscreen-aware ALT+Tab
-- Restores the Hyprland <= 0.52 behaviour: when the focused window is
-- fullscreen, ALT+Tab hands fullscreen to the next window instantly.
--
-- With misc.on_focus_under_fullscreen = 1, Hyprland 0.53+ already moves
-- fullscreen to the newly focused window, but animates it growing from its
-- tiled size. 0.51 skipped ("warped") that animation in its switchToWindow;
-- 0.56 no longer does. We get the same result by disabling the animations
-- involved for the duration of the switch.

local ANIMATIONS = require("lua.rules.animations")

local M = {}

-- windowsMove: size/position change (tiled -> fullscreen)
-- fadeIn: fullscreen show/hide fade of the windows involved
local SKIPPED = { windowsMove = true, fadeIn = true }

local restore_timer = nil

local function set_skipped(disabled)
  for _, spec in ipairs(ANIMATIONS) do
    if SKIPPED[spec.leaf] then
      if disabled then
        hl.animation({ leaf = spec.leaf, enabled = false })
      else
        hl.animation(spec)
      end
    end
  end
end

function M.cycle()
  local win = hl.get_active_window()
  if not win or win.fullscreen == 0 then
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
    return
  end

  set_skipped(true)
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
  -- Animations are started synchronously by the dispatch above, so they have
  -- already been warped by now; restore the config right after.
  if not restore_timer then
    restore_timer = hl.timer(function()
      restore_timer = nil
      set_skipped(false)
    end, { timeout = 20, type = "oneshot" })
  end
end

return M
