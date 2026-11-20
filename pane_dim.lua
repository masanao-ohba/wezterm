-- Dimming of inactive panes. WezTerm has no per-pane opacity; inactive_pane_hsb
-- (hue/saturation/brightness of panes without focus) is the only per-pane knob.
-- tabs.lua applies DIMMED as the default, and toggle() overrides it per window.
local M = {}

M.DIMMED = { saturation = 0.80, brightness = 0.30 }
M.UNDIMMED = { saturation = 1.0, brightness = 1.0 }

-- Config overrides belong to the window, so the toggle affects only that window and
-- survives config reloads.
function M.toggle(window)
  local overrides = window:get_config_overrides() or {}
  if overrides.inactive_pane_hsb then
    overrides.inactive_pane_hsb = nil
  else
    overrides.inactive_pane_hsb = M.UNDIMMED
  end
  window:set_config_overrides(overrides)
end

return M
