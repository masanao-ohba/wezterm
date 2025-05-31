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

wezterm.on("update-right-status", function(window, pane)
  local wday = os.date("*t").wday
  -- 指定子の後に半角スペースをつけないと正常に表示されなかった
  local wday_ja = string.format("(%s)", day_of_week_ja[wday])
  local date = wezterm.strftime("📆 %Y-%m-%d " .. wday_ja .. " ⏰ %H:%M:%S")

  window:set_right_status(wezterm.format({
    { Text = date .. "  " },
  }))
end)

return config

