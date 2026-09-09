-- Workspace distribution: 1,2 on LG | 3,4,5,6,7,8,9,10 on ASUS
-- Last updated: 2026-09-09

local LG = "HDMI-A-2"      -- Secondary monitor (left, portrait)
local ASUS = "DP-2"         -- Primary monitor (right)

-- Secondary monitor (LG - left, portrait)
hl.workspace_rule({ workspace = "1", monitor = LG })
hl.workspace_rule({ workspace = "2", monitor = LG })

-- Primary monitor (ASUS - right)
hl.workspace_rule({ workspace = "3", monitor = ASUS })
hl.workspace_rule({ workspace = "4", monitor = ASUS })
hl.workspace_rule({ workspace = "5", monitor = ASUS })
hl.workspace_rule({ workspace = "6", monitor = ASUS })
hl.workspace_rule({ workspace = "7", monitor = ASUS })
hl.workspace_rule({ workspace = "8", monitor = ASUS })
hl.workspace_rule({ workspace = "9", monitor = ASUS })
hl.workspace_rule({ workspace = "10", monitor = ASUS })
