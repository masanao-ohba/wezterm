local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 自動設定リロード
config.automatically_reload_config = true

-- スクロールバックバッファ制限（デフォルト3500）
config.scrollback_lines = 1000

return config

