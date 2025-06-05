local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 自動設定リロード
config.automatically_reload_config = true

-- 初期ディレクトリ
config.default_cwd = os.getenv("HOME") .. "/workspace"

require("events_right_status")

return config

