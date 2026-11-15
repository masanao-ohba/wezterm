local wezterm = require("wezterm")

-- Converts the progress that apps report from a tab's panes (OSC 9;4) into a
-- one-character mark placed before the tab name. PaneInformation.progress is one of:
--   "None" / "Indeterminate" / { Percentage = n } / { Error = n }
local M = {}

-- A percentage is shown as a circle divided into 8 slices.
local SLICES = {
  wezterm.nerdfonts.md_circle_slice_1,
  wezterm.nerdfonts.md_circle_slice_2,
  wezterm.nerdfonts.md_circle_slice_3,
  wezterm.nerdfonts.md_circle_slice_4,
  wezterm.nerdfonts.md_circle_slice_5,
  wezterm.nerdfonts.md_circle_slice_6,
  wezterm.nerdfonts.md_circle_slice_7,
  wezterm.nerdfonts.md_circle_slice_8,
}
local INDETERMINATE = wezterm.nerdfonts.md_progress_clock
local ERROR = wezterm.nerdfonts.md_alert_circle

-- Priority for choosing which progress represents a tab that has several panes.
-- What the user needs to know comes first: error > percentage > busy (no percentage).
local RANK = { none = 0, indeterminate = 1, percentage = 2, error = 3 }

local function kind(progress)
  if type(progress) == "table" then
    if progress.Error ~= nil then
      return "error"
    end
    if progress.Percentage ~= nil then
      return "percentage"
    end
    return "none"
  end
  if progress == "Indeterminate" then
    return "indeterminate"
  end
  return "none"
end

local function slice(pct)
  local n = math.max(0, math.min(100, tonumber(pct) or 0))
  return SLICES[math.max(1, math.ceil(n / 100 * #SLICES))]
end

-- Picks the representative progress from all panes of a tab and returns the mark
-- to show; "" when there is no progress.
-- Pass tab.panes, not active_pane, so that work running in an inactive pane (the
-- other side of a split) is picked up too.
function M.indicator(panes)
  local best, best_kind = nil, "none"
  for _, pane in ipairs(panes or {}) do
    local k = kind(pane.progress)
    if RANK[k] > RANK[best_kind] then
      best, best_kind = pane.progress, k
    end
  end

  if best_kind == "error" then
    return ERROR
  elseif best_kind == "percentage" then
    return slice(best.Percentage)
  elseif best_kind == "indeterminate" then
    return INDETERMINATE
  end
  return ""
end

return M
