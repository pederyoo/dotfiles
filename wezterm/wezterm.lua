-- Initialize Configuration
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local opacity = 1
local transparent_bg = "rgba(22, 24, 26, " .. opacity .. ")"

--- Get the current operating system
--- @return "windows"| "linux" | "macos"
local function get_os()
  local target = wezterm.target_triple
  if target:find("windows") then
    return "windows"
  elseif target:find("darwin") then
    return "macos"
  else
    return "linux"
  end
end

local host_os = get_os()

-- Font Configuration
local emoji_font = "Segoe UI Emoji"
config.font = wezterm.font_with_fallback({
    {
        family = "Hack Nerd Font Mono",
        weight = "Regular",
    },
    emoji_font,
})
config.font_size = 10

-- Color Configuration
config.colors = require("cyberdream")
config.force_reverse_video_cursor = true

-- Window Configuration
config.initial_rows = 30
config.initial_cols = 120
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.window_background_opacity = opacity
config.window_background_image = (os.getenv("WEZTERM_CONFIG_FILE") or ""):gsub("wezterm.lua", "bg-blurred.png")
config.window_close_confirmation = "NeverPrompt"
config.win32_system_backdrop = "Acrylic"
config.integrated_title_button_alignment = "Right" 

config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

config.window_frame = {
  active_titlebar_bg = "rgba(0,0,0,0)",
  inactive_titlebar_bg = "rgba(0,0,0,0)",
  active_titlebar_fg = "#666666",
  inactive_titlebar_fg = "#666666",
  button_fg = "#cccccc",
  button_bg = "rgba(0,0,0,0)",
  button_hover_fg = "#ffffff",
  button_hover_bg = "#89b4fa",
}

config.window_frame.font = wezterm.font_with_fallback({
  { family = "Hack Nerd Font Mono", weight = "Regular" },
  { family = "Segoe UI Emoji" },
})

-- Performance Settings
config.max_fps = 144
config.animation_fps = 60
config.cursor_blink_rate = 250

-- Tab Bar Configuration
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.colors.tab_bar = {
  background        = "rgba(0,0,0,0)",
  active_tab        = { bg_color="rgba(0,0,0,0)", fg_color="#888888" },
  inactive_tab      = { bg_color="rgba(0,0,0,0)", fg_color="#444444" },
  inactive_tab_edge = "rgba(0,0,0,0)",
  new_tab           = { bg_color="rgba(0,0,0,0)", fg_color="#555555" },
  new_tab_hover     = { bg_color="rgba(0,0,0,0)", fg_color="#888888" },
}

-- Tab Formatting
wezterm.on("format-window-title", function(...) return "" end)

wezterm.on("format-tab-title", function(...) return "" end)

wezterm.on("update-right-status", function(window, pane)
  local wezterm = require("wezterm")

  local elements = {}
  for _, b in ipairs(wezterm.battery_info()) do
    local pct = math.floor(b.state_of_charge * 100 + 0.5)
    local icon = "🔋"
    if pct >= 90 then icon = ""
    elseif pct >= 70 then icon = ""
    elseif pct >= 50 then icon = ""
    elseif pct >= 25 then icon = ""
    else icon = "" end

    table.insert(elements, {
      Foreground = { Color = "#888888" },
      Text = string.format(" %s%d%% ", icon, pct),
    })
  end

  table.insert(elements, {
    Foreground = { Color = "#888888" },
    Text = wezterm.strftime(" %H:%M "),
  })

  window:set_right_status(wezterm.format(elements))
end)

-- Keybindings
config.keys = {
  -- Pane splitting
  {
    key = "s", mods = "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "v", mods = "CTRL|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  -- Pane navigation (Vim-style)
  { key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

  -- Pane resizing
  { key = "LeftArrow",  mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
  { key = "RightArrow", mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow",    mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
  { key = "DownArrow",  mods = "ALT", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },

  -- Tab management
  { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
  { key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

  -- Clipboard
  { key = "C", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
  { key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
}

-- Default Shell Configuration
config.default_prog = { "powershell.exe" }

-- OS-Specific Overrides
if host_os == "linux" then
    emoji_font = "Noto Color Emoji"
    config.default_prog = { "bash" }
    config.front_end = "WebGpu"
    config.enable_wayland = true
    config.window_background_image = os.getenv("HOME") .. "/.config/wezterm/bg-blurred.png"
    config.window_decorations = nil -- use system decorations
end

if host_os == "windows" then
  config.default_domain = "WSL:Ubuntu-24.04"
end

return config
