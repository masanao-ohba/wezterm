local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 20.0
-- config.font = wezterm.font("Hack Nerd Font Mono")
config.font = wezterm.font_with_fallback {
  { family = 'Ricty Diminished', weight = 'Regular' },
  { family = 'Hack Nerd Font Mono', weight = 'Regular', assume_emoji_presentation = true },
}
config.freetype_load_target = 'Light'
config.freetype_render_target = 'Light'
config.use_ime = true

config.color_scheme = 'Moonfly (Gogh)'
config.inactive_pane_hsb = {
  saturation = 1.10,  -- 彩度を10%増加
  brightness = 1.30,  -- 明度を30%増加
}

return config
