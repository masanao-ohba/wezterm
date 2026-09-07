local wezterm = require("wezterm")
local tab_title = require("tab_title")

-- 台形 (下底が広い) にするため左右のキャップを鏡像にする。
-- どちらもタブ色でグリフを描き、地色をバー色にする。
local CAP_LEFT = wezterm.nerdfonts.ple_lower_right_triangle -- U+E0BA
local CAP_RIGHT = wezterm.nerdfonts.ple_lower_left_triangle -- U+E0B8

local BAR = "#332a57"
local ACTIVE = { bg = "#9c7af2", fg = "#ffffff" }
local INACTIVE = { bg = "#5c6d74", fg = "#ffffff" }

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local colors = tab.is_active and ACTIVE or INACTIVE
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  local label = tab_title.label(tab.tab_index + 1, tab.tab_title, pane.title, cwd and cwd.file_path or nil)

  return {
    { Background = { Color = BAR } },
    { Foreground = { Color = colors.bg } },
    { Text = CAP_LEFT },

    { Background = { Color = colors.bg } },
    { Foreground = { Color = colors.fg } },
    { Text = label },

    { Background = { Color = BAR } },
    { Foreground = { Color = colors.bg } },
    { Text = CAP_RIGHT },
  }
end)
