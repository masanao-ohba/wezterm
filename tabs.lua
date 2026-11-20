local wezterm = require("wezterm")
local colors = require("colors")
local pane_dim = require("pane_dim")
local config = wezterm.config_builder()

-- Hide the title bar
config.window_decorations = "RESIZE"
-- Show tabs in the tab bar
config.show_tabs_in_tab_bar = true
-- Keep the tab bar visible even when there is only one tab
config.hide_tab_bar_if_only_one_tab = false
-- The retro tab bar is drawn with the terminal font. The fancy tab bar is kept for
-- the look of its UI font. However, fancy renders with a different font and cell
-- width, so centering the tabs by padding the left status with spaces does not work.
config.use_fancy_tab_bar = true

-- The tab name width is decided dynamically from the window width (title_width in
-- events_tab.lua). Its upper bound, tab_title.MAX_WIDTH (23 cells), plus the left
-- and right caps and "N: " must fit within this width, or wezterm truncates the
-- title a second time.
config.tab_max_width = 32

-- Tab bar frame
config.window_frame = {
  -- The tab caps and the left/right status sit on this base color. The alternating
  -- light/dark palette assumes a mid-lightness base, so a solid color is used
  -- instead of transparency.
  inactive_titlebar_bg = colors.BAR,
  active_titlebar_bg = colors.BAR,
  font_size = 15,
}

-- Match the tab bar to the background color
config.window_background_gradient = {
  colors = { "#000000" },
}

-- Hide the new-tab button
config.show_new_tab_button_in_tab_bar = false
-- Available in nightly only
-- Hide the close button on tabs
config.show_close_tab_button_in_tabs = false

-- Hide the edge between tabs
config.colors = {
  tab_bar = {
    background = colors.BAR,
    inactive_tab_edge = "none",
  },
}

-- Dim inactive panes by default; LEADER + d toggles it per window (pane_dim.lua)
config.inactive_pane_hsb = pane_dim.DIMMED

require("events_tab")

return config

