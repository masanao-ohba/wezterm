local wezterm = require("wezterm")

-- Rules for deciding the tab name. Arguments are plain strings only, so this does
-- not depend on the caller's types.
local M = {}

M.MAX_WIDTH = 23

-- Tab number, progress mark, and left/right padding. label and overhead go through
-- the same builder, so the width estimate is not left behind when the format changes.
-- indicator is the mark returned by tab_progress.indicator(); "" when there is no
-- progress.
local function prefix(number, indicator)
  local mark = (indicator and indicator ~= "") and (indicator .. " ") or ""
  return " " .. number .. ": " .. mark
end
local SUFFIX = " "

-- A title that only names the shell cannot identify a tab, so fall back to the cwd
local SHELL_TITLES = { zsh = true, bash = true, sh = true, fish = true }

local function basename(path)
  if not path or path == "" then
    return nil
  end
  return path:gsub("/+$", ""):match("([^/]+)$")
end

-- Use the first available of: manual name > pane title > cwd basename.
-- A name set with tab:set_title() is kept apart from the inputs to automatic naming,
-- so automatic updates never overwrite a manual name.
function M.resolve(explicit, pane_title, cwd_path)
  if explicit and explicit ~= "" then
    return explicit
  end
  if pane_title and pane_title ~= "" and not SHELL_TITLES[pane_title] then
    return pane_title
  end
  return basename(cwd_path) or pane_title or ""
end

-- Truncate keeping the beginning, because the beginning of a title identifies it
-- best. width is the limit the caller computed from the window width; defaults to
-- MAX_WIDTH.
function M.truncate(text, width)
  width = width or M.MAX_WIDTH
  if wezterm.column_width(text) <= width then
    return text
  end
  return wezterm.truncate_right(text, math.max(width - 1, 1)) .. "…"
end

-- The string shown in the tab, excluding the left and right caps.
function M.label(number, indicator, explicit, pane_title, cwd_path, width)
  return prefix(number, indicator) .. M.truncate(M.resolve(explicit, pane_title, cwd_path), width) .. SUFFIX
end

-- Cells that label uses besides the tab name. Grows when the number reaches two
-- digits or a progress mark is added.
function M.overhead(number, indicator)
  return wezterm.column_width(prefix(number, indicator) .. SUFFIX)
end

return M
