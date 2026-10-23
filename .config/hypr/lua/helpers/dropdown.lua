-- Dropdown terminal
-- Toggled with SUPER+SHIFT+Return. Replaces scripts/Dropterminal.sh: that
-- script spawned ~15 hyprctl/jq processes per press and slept 100ms before
-- hiding. Running inside Hyprland makes the toggle instant.
--
-- Hidden = parked on special:scratchpad. Shown = floating + pinned on the
-- current workspace, at its last position (or the default box below).

local M = {}

local CLASS = "DropdownTerminal"
local SPECIAL = "special:scratchpad"
local TERMINAL = "kitty"

-- Default size as percentage of the monitor, placed at the gaps_out corner
local WIDTH_PERCENT = 54
local HEIGHT_PERCENT = 67

-- Last shown geometry, so a moved/resized dropdown comes back where it was:
-- { x, y, w, h, monitor }
local saved = nil

local function gaps_out()
  local g = hl.get_config("general.gaps_out")
  if type(g) == "table" then return g.top or g[1] or 0 end
  return tonumber(g) or 0
end

local function default_box(mon)
  local w, h = mon.width / mon.scale, mon.height / mon.scale
  if mon.transform % 2 == 1 then w, h = h, w end
  local gap = gaps_out()
  return {
    x = mon.x + gap,
    y = mon.y + gap,
    w = math.floor(w * WIDTH_PERCENT / 100),
    h = math.floor(h * HEIGHT_PERCENT / 100),
  }
end

-- With several dropdowns around (e.g. leftovers), prefer a visible one, then
-- the most recently focused.
local function find()
  local best
  for _, w in ipairs(hl.get_windows({ class = CLASS })) do
    if w.mapped then
      local hidden = w.workspace and w.workspace.special
      if not hidden then return w, false end
      if not best or w.focus_history_id < best.focus_history_id then best = w end
    end
  end
  if best then return best, true end
  return nil
end

local function place(win, box)
  hl.dispatch(hl.dsp.window.resize({ x = box.w, y = box.h, window = win }))
  hl.dispatch(hl.dsp.window.move({ x = box.x, y = box.y, window = win }))
end

local function show(win)
  local mon = hl.get_active_monitor()
  local ws = hl.get_active_workspace()
  local box = (saved and saved.monitor == mon.name) and saved or default_box(mon)

  hl.dispatch(hl.dsp.window.move({ workspace = tostring(ws.id), silent = true, window = win }))
  place(win, box)
  if not win.pinned then
    hl.dispatch(hl.dsp.window.pin({ window = win }))
  end
  hl.dispatch(hl.dsp.focus({ window = win }))
end

local function hide(win)
  saved = {
    x = win.at.x, y = win.at.y, w = win.size.x, h = win.size.y,
    monitor = win.monitor and win.monitor.name,
  }
  if win.pinned then
    hl.dispatch(hl.dsp.window.pin({ window = win }))
  end
  hl.dispatch(hl.dsp.window.move({ workspace = SPECIAL, silent = true, window = win }))

  -- A silent move leaves keyboard focus on the now-hidden terminal; give it
  -- back to the most recently focused window on the current workspace.
  local ws = hl.get_active_workspace()
  local prev
  for _, w in ipairs(ws and hl.get_workspace_windows(ws.id) or {}) do
    if w.address ~= win.address and w.mapped
      and (not prev or w.focus_history_id < prev.focus_history_id) then
      prev = w
    end
  end
  if prev then
    hl.dispatch(hl.dsp.focus({ window = prev }))
  end
end

-- Start the terminal. `hidden` parks it in the scratchpad (used at boot).
function M.spawn(hidden)
  local box = default_box(hl.get_active_monitor())
  local rules = {
    float = true,
    size = box.w .. " " .. box.h,
    move = box.x .. " " .. box.y,
  }
  if hidden then
    rules.workspace = SPECIAL .. " silent"
  else
    rules.pin = true
  end
  hl.exec_cmd(TERMINAL .. " --class " .. CLASS, rules)
end

function M.toggle()
  local win, hidden = find()
  if not win then
    M.spawn(false)
  elseif hidden then
    show(win)
  else
    hide(win)
  end
end

-- Re-apply the default geometry after a gap change (scripts/GapControl.sh)
function M.reposition()
  saved = nil
  local win, hidden = find()
  if win and not hidden then
    place(win, default_box(win.monitor or hl.get_active_monitor()))
  end
end

return M
