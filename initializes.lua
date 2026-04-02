local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 自動設定リロード
config.automatically_reload_config = true

return config

