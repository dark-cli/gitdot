# Alacritty icon options for Waybar

Use one of these as the value for `"class<[Aa]lacritty|alacritty-dropterm>"` in `ModulesWorkspaces` (window-rewrite section). All require a **Nerd Font** (e.g. JetBrainsMono Nerd Font, FiraCode Nerd Font).

---

## 1. Console (current – same as Kitty/Konsole)
**Nerd Font:** Material Design Icons · **Codepoint:** U+EBC6

```
"class<[Aa]lacritty|alacritty-dropterm>": " ",
```
Rounded console/terminal icon. Same as your current Alacritty and Kitty.

---

## 2. Terminal (like Kitty-dropterm)
**Nerd Font:** Font Awesome · **Codepoint:** U+F41C

```
"class<[Aa]lacritty|alacritty-dropterm>": " ",
```
Classic `>_` terminal prompt style. Same as `kitty-dropterm` and workspace 1.

---

## 3. Terminal (like Ghostty)
**Nerd Font:** Devicons · **Codepoint:** U+E795

```
"class<[Aa]lacritty|alacritty-dropterm>": "  ",
```
Terminal with badge. Same as Ghostty. (Leading space matches your Ghostty rule.)

---

## 4. Terminal (like Wezterm)
**Nerd Font:** Codicons (VS Code) · **Codepoint:** U+EA85

```
"class<[Aa]lacritty|alacritty-dropterm>": "  ",
```
VS Code–style terminal. Same as Wezterm. (Leading space matches your Wezterm rule.)

---

## 5. Standard Unicode (no Nerd Font needed)

**Black right-pointing pointer:** U+25B6 `▶`

```
"class<[Aa]lacritty|alacritty-dropterm>": "▶ ",
```

**Desktop / monitor:** U+1F5A5 `🖥` (emoji)

```
"class<[Aa]lacritty|alacritty-dropterm>": "🖥 ",
```

**Laptop:** U+1F4BB `💻` (emoji)

```
"class<[Aa]lacritty|alacritty-dropterm>": "💻 ",
```

---

## How to change

Edit `~/.config/waybar/ModulesWorkspaces`, find around **line 201**:

```json
"class<[Aa]lacritty|alacritty-dropterm>": " ",
```

Replace the part in quotes on the right with one of the options above (including the trailing space if you want a gap before the next element). Restart Waybar or run `killall waybar; waybar &` to apply.
