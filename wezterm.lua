----------------------------------------------------
-- 0. 初期化
----------------------------------------------------
local wezterm = require("wezterm")
local config = wezterm.config_builder()

function merge_config(config, new_config)
  for k, v in pairs(new_config) do
    config[k] = v
  end
end

local initialize_config = require("initializes")
merge_config(config, initialize_config)

----------------------------------------------------
-- 1. 背景
----------------------------------------------------
config.background = require("background")
----------------------------------------------------

----------------------------------------------------
-- 2. フォント表示
----------------------------------------------------
local font_config = require("fonts")
merge_config(config, font_config)

----------------------------------------------------
-- 3. タブ表示
----------------------------------------------------
local tab_config = require("tabs")
merge_config(config, tab_config)

----------------------------------------------------
-- 4. タブバー
----------------------------------------------------
require("tabline")

----------------------------------------------------
-- 5. キーマッピング
----------------------------------------------------
-- OPT -> ALT
config.disable_default_key_bindings = true
config.keys = require("keymaps").keys
config.key_tables = require("keymaps").key_tables
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.leader = { key = "j", mods = "CTRL", timeout_milliseconds = 2000 }

----------------------------------------------------
-- 6. Log Activity
----------------------------------------------------
require("activities")


return config
