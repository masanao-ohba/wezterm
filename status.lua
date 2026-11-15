local wezterm = require("wezterm")
local colors = require("colors")
local workspaces = require("workspaces")

-- Renders the left and right status. It also answers the cell-width queries
-- (left_cells / right_cells). Both must go through the same builder functions so
-- that the widths change along with the format. events_tab.lua subtracts these
-- widths to size the tabs.
local M = {}

-- Boundary between the workspace name and the date/time. The upper side takes the
-- left neighbor's color and the lower side the right neighbor's.
-- Glyphs from U+E0C0 onward (flames, waves, trapezoids, etc.) come from the font,
-- and their advance width does not match the cell width, which breaks the layout.
-- Choose from U+E0B0-U+E0BE, which wezterm draws itself.
local SECTION_SEPARATOR = wezterm.nerdfonts.pl_left_hard_divider -- U+E0B0

-- Padding on both sides of a chip, and base-color padding between the date/time
-- and the tabs.
local PAD = "  "
local GAP = " "

local WEEKDAYS = { "日", "月", "火", "水", "木", "金", "土" }

local function chip(text)
  return PAD .. text .. PAD
end

local function active_mode(window)
  local key_table = window:active_key_table()
  if key_table and key_table:find("_mode$") then
    return key_table
  end
  return "normal_mode"
end

local function mode_text(mode)
  return mode:gsub("_mode", ""):upper()
end

local function current_datetime()
  local now = wezterm.time.now()
  local weekday = WEEKDAYS[tonumber(now:format("%w")) + 1]
  return wezterm.nerdfonts.md_calendar_clock
    .. " "
    .. now:format("%m/%d(")
    .. weekday
    .. now:format(") %H:%M")
end

-- Cells occupied by the left status. The workspace name differs per window, so
-- this takes the window id.
function M.left_cells(window_id)
  local cells = wezterm.column_width(chip(current_datetime()) .. GAP)
  local workspace = workspaces.get_label(window_id) or ""
  if workspace ~= "" then
    cells = cells + wezterm.column_width(chip(workspace) .. SECTION_SEPARATOR)
  end
  return cells
end

-- Cells occupied by the right status. The mode changes with state, so this returns
-- the widest one.
function M.right_cells()
  local cells = 0
  for mode in pairs(colors.MODE) do
    cells = math.max(cells, wezterm.column_width(chip(mode_text(mode))))
  end
  return cells
end

-- Keep all state local to this handler. If it lived in module variables, the
-- update-status handlers of multiple windows would overwrite each other's values
-- when they run nested.
wezterm.on("update-status", function(window)
  local elements = {}

  local function push(background, foreground, text, intensity)
    table.insert(elements, { Background = { Color = background } })
    table.insert(elements, { Foreground = { Color = foreground } })
    if intensity then
      table.insert(elements, { Attribute = { Intensity = intensity } })
    end
    table.insert(elements, { Text = text })
  end

  local workspace = workspaces.get_label(window:window_id()) or ""
  if workspace ~= "" then
    push(colors.WORKSPACE.bg, colors.WORKSPACE.fg, chip(workspace), "Bold")
    push(colors.DATETIME.bg, colors.WORKSPACE.bg, SECTION_SEPARATOR)
  end
  push(colors.DATETIME.bg, colors.DATETIME.fg, chip(current_datetime()), "Normal")

  -- The right edge of the date/time is cut straight, with no separator; only
  -- base-color padding goes between it and the tabs.
  push(colors.BAR, colors.BAR, GAP)

  window:set_left_status(wezterm.format(elements))

  -- The left edge of the mode is also cut straight, with no separator.
  local mode = active_mode(window)
  local mode_colors = colors.MODE[mode] or colors.MODE.normal_mode
  window:set_right_status(wezterm.format({
    { Background = { Color = mode_colors.bg } },
    { Foreground = { Color = mode_colors.fg } },
    { Attribute = { Intensity = "Bold" } },
    { Text = chip(mode_text(mode)) },
  }))
end)

return M
