-- Monitor profile: dual-monitor (LG secondary left + ASUS primary right)
-- LG secondary monitor: 1600x900 rotated 90° = 900x1600 physical size
hl.monitor({
    output = "HDMI-A-2",
    mode = "1600x900@60.0",
    position = "0x0",
    scale = 0.78,
    vrr = 0,
    transform = 1
})

-- ASUS primary monitor: Always 2560x1440@165Hz
hl.monitor({
    output = "DP-2",
    mode = "2560x1440@165.0",
    position = "1154x0",
    scale = 1.0,
    vrr = 1
})
