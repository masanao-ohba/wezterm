local wezterm = require("wezterm")
local colors = require("colors")
local status = require("status")
local tab_title = require("tab_title")
local tab_progress = require("tab_progress")

-- The left and right caps are mirror images, forming a trapezoid wider at the bottom.
-- Both draw the glyph in the tab color, with the bar color as the background.
local CAP_LEFT = wezterm.nerdfonts.ple_lower_right_triangle -- U+E0BA
local CAP_RIGHT = wezterm.nerdfonts.ple_lower_left_triangle -- U+E0B8
local CAP_CELLS = 2

-- Never shrink a tab name below this: a fragment of the name is easier to pick
-- out than almost nothing.
local MIN_WIDTH = 6

-- Cells available to the whole tab bar. The fancy tab bar is drawn at
-- window_frame.font_size, while PaneInformation counts cells in the content font,
-- so this estimates from the size ratio. The font width ratio is not available, so
-- multiply by 0.9 to underestimate. An overestimate makes the tabs overlap the mode
-- display on the right, so always err on the narrow side.
local function tabbar_cells(panes, config)
  local cols = 0
  for _, pane in ipairs(panes) do
    cols = math.max(cols, pane.left + pane.width)
  end
  if cols == 0 then
    return nil
  end
  local frame_size = (config.window_frame and config.window_frame.font_size) or config.font_size
  return math.floor(cols * (config.font_size / frame_size) * 0.9)
end

-- Maximum title cells per tab. When the window width is unavailable, only the
-- max_width wezterm passes and MAX_WIDTH decide it.
local function title_width(tab, tabs, panes, config, max_width, indicator)
  local overhead = CAP_CELLS + tab_title.overhead(tab.tab_index + 1, indicator)
  local width = math.min(tab_title.MAX_WIDTH, max_width - overhead)

  local cells = tabbar_cells(panes, config)
  if cells then
    local room = cells - status.left_cells(tab.window_id) - status.right_cells()
    width = math.min(width, math.floor(room / math.max(#tabs, 1)) - overhead)
  end

  return math.max(MIN_WIDTH, width)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local tab_colors = tab.is_active and colors.TAB_ACTIVE or colors.TAB_INACTIVE
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  -- Progress is collected from every pane in the tab. format-tab-title is called
  -- again whenever what is shown changes, so computing it here each time is enough.
  local indicator = tab_progress.indicator(tab.panes)
  local label = tab_title.label(
    tab.tab_index + 1,
    indicator,
    tab.tab_title,
    pane.title,
    cwd and cwd.file_path or nil,
    title_width(tab, tabs, panes, config, max_width, indicator)
  )

  return {
    { Background = { Color = colors.BAR } },
    { Foreground = { Color = tab_colors.bg } },
    { Text = CAP_LEFT },

    { Background = { Color = tab_colors.bg } },
    { Foreground = { Color = tab_colors.fg } },
    { Text = label },

    { Background = { Color = colors.BAR } },
    { Foreground = { Color = tab_colors.bg } },
    { Text = CAP_RIGHT },
  }
end)
