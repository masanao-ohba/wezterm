----------------------------------------------------
-- 0. 初期化
----------------------------------------------------
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 自動設定リロード
config.automatically_reload_config = true

-- 初期ディレクトリ
config.default_cwd = os.getenv("HOME") .. "/workspace"

-- イベントハンドラ
-- 起動時に画面を最大化
wezterm.on("gui-startup", function()
    local _, _, window = mux.spawn_window({})
    window:gui_window():maximize()
end)

----------------------------------------------------
-- 1. 背景
----------------------------------------------------
config.background = require("background")
----------------------------------------------------

----------------------------------------------------
-- 2. フォント表示
----------------------------------------------------
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

----------------------------------------------------
-- 3. タブ表示
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
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
        inactive_tab_edge = "none",
    },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = "#5c6d74"
    local foreground = "#FFFFFF"
    local edge_background = "none"

    if tab.is_active then
        background = "#9c7af2"
        foreground = "#FFFFFF"
    end

    local edge_foreground = background
    local title = tab.active_pane.title

    -- タイトルが長い場合は省略
    local function get_last_n_chars(str, n)
        if #str <= n then
            return str
        else
            return "…" .. string.sub(str, -n + 1)
        end
    end

    -- プロセス名に基づいてタイトルを取得する関数(nodeとかmakeとか表示)
    local function get_process_name(pane)
        local process_name = pane.foreground_process_name

        return process_name:match("([^/]+)$") or ""

    end

    -- カスタムタイトルを取得する関数
    local function get_custom_title(pane)
        local process_name = get_process_name(pane)

        if process_name ~= "zsh" then
            return process_name
        else
            return get_last_n_chars(title, 23)
        end

        return process_name
    end

    -- カスタムタイトルを取得
    local custom_title = get_custom_title(tab.active_pane)

    return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = " " .. (tab.tab_index + 1) .. ": " .. custom_title .. " " },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
    }
end)

----------------------------------------------------
-- 4. キーマッピング
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keymap").keys
config.key_tables = require("keymap").key_tables
config.leader = { key = "j", mods = "CTRL", timeout_milliseconds = 2000 }

return config
