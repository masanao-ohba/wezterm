local wezterm = require("wezterm")
local colors = require("colors")
local config = wezterm.config_builder()

-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = false
-- retro タブバーはターミナルのフォントで描かれる。fancy の UI フォントの
-- 見た目を優先するため fancy のまま使う。ただし fancy は別フォント・別桁で
-- 描画されるため、左ステータスへの空白詰めによるタブ中央寄せは成立しない。
config.use_fancy_tab_bar = true

-- タブ名の桁数はウィンドウ幅から動的に決まる (events_tab.lua の title_width)。
-- その上限である tab_title.MAX_WIDTH (23桁) に左右のキャップと "N: " を足しても
-- 収まる幅にしておかないと wezterm 側で二重に切られる。
config.tab_max_width = 32

-- タブバーの透過
config.window_frame = {
  -- タブのキャップと左右ステータスがこの地色の上に乗る。明暗を交互にする
  -- 配色が中明度の地色を前提にしているため、透過ではなく実色を敷く。
  inactive_titlebar_bg = colors.BAR,
  active_titlebar_bg = colors.BAR,
  font_size = 15,
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    background = colors.BAR,
    inactive_tab_edge = "none",
  },
}

config.inactive_pane_hsb = { saturation = 0.80, brightness = 0.30 }

require("events_tab")

return config

