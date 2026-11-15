-- Tab bar palette. status.lua (left/right status), events_tab.lua (tabs), and
-- tabs.lua (the base color itself) all build light and dark steps on the same base
-- color, so every value must be defined here, in exactly one place.
local M = {}

-- Base color of the bar: a slate one step lighter than the content background
-- (black), so the boundary between bar and pane shows as a difference in base color.
-- Each section steps its shade from this base:
-- light (workspace) -> medium (date/time) -> dark (base).
M.BAR = "#232830"

M.WORKSPACE = { bg = "#dfe6ec", fg = "#1b222b" }
M.DATETIME = { bg = "#3b6b78", fg = "#e6f2f5" }

-- Each mode gets its own hue so it can be told apart by color, not only by text.
-- Mid lightness with high saturation keeps them from blending into either the base
-- color or the achromatic workspace chip.
M.MODE = {
  normal_mode = { bg = "#2f9e63", fg = "#f0fbf4" },
  copy_mode = { bg = "#c8912a", fg = "#1f1704" },
  search_mode = { bg = "#c2553a", fg = "#fdeee9" },
}

-- The active tab shares its color with the workspace name chip: both mark
-- "where you are now", so they belong to the same color family. The date/time sits
-- between them, so they are never adjacent.
M.TAB_ACTIVE = { bg = "#dfe6ec", fg = "#1b222b" }
M.TAB_INACTIVE = { bg = "#3d4552", fg = "#aab4c0" }

return M
