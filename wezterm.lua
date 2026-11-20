----------------------------------------------------
-- 0. Initialization
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
-- 1. Background
----------------------------------------------------
config.background = require("background")
----------------------------------------------------

----------------------------------------------------
-- 2. Fonts
----------------------------------------------------
local font_config = require("fonts")
merge_config(config, font_config)

----------------------------------------------------
-- 3. Tabs
----------------------------------------------------
local tab_config = require("tabs")
merge_config(config, tab_config)

----------------------------------------------------
-- 4. Status bar
----------------------------------------------------
require("status")

----------------------------------------------------
-- 5. Key mappings
----------------------------------------------------
-- OPT -> ALT
config.disable_default_key_bindings = true
local keymaps = require("keymaps")
config.keys = keymaps.keys
config.key_tables = keymaps.key_tables
config.leader = keymaps.leader
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

----------------------------------------------------
-- 7. Workspace Setup on Startup
----------------------------------------------------
require("workspaces").setup()

return config
