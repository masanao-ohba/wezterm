local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Reload the config automatically
config.automatically_reload_config = true

-- Scrollback buffer limit (default 3500)
config.scrollback_lines = 1000

return config

