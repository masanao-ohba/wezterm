local wezterm = require("wezterm")

local log_dir = os.getenv("HOME") .. "/.config/wezterm/activity_logs"
local log_file = log_dir .. "/workspace.log"

-- スロットリング設定（秒）
local THROTTLE_INTERVAL = 30
local last_input_time = 0
local last_mouse_time = 0

-- ログディレクトリが存在しない場合は作成
local function ensure_log_dir()
  local stat = wezterm.read_dir(log_dir)
  if not stat then
    -- ディレクトリが存在しない場合は作成を試みる
    os.execute("mkdir -p " .. log_dir)
  end
end

local function log_input(event_name, window, pane)
  ensure_log_dir()

  local ws = window:active_workspace()
  local now = os.date("!%Y-%m-%d %H:%M:%S")
  local entry = string.format("%s,%s,%s\n", now, ws, event_name)

  local f = io.open(log_file, "a")
  if f then
    f:write(entry)
    f:close()
    -- デバッグ用：ログが書き込まれたことを確認
    wezterm.log_info("Logged: " .. entry:gsub("\n", ""))
  else
    wezterm.log_error("Failed to open log file: " .. log_file)
  end
end

-- スロットリング用のヘルパー関数
local function should_log_with_throttle(last_time, current_time)
  return (current_time - last_time) >= THROTTLE_INTERVAL
end

wezterm.on("window-focus-changed", function(window, pane)
  if window:is_focused() then
    log_input("activated", window, pane)
  else
    log_input("deactivated", window, pane)
  end
end)

wezterm.on("window-config-reloaded", function(window, pane)
  log_input("config_reloaded", window, pane)
end)

-- キー入力イベント（スロットリング付き）
wezterm.on("key-down", function(key, mods, window, pane)
  local current_time = os.time()
  if should_log_with_throttle(last_input_time, current_time) then
    last_input_time = current_time
    log_input("key_input", window, pane)
  end
  return false  -- イベントを他のハンドラに渡す
end)

-- マウスイベント（スロットリング付き）
wezterm.on("mouse-event", function(event, window, pane)
  local current_time = os.time()
  if should_log_with_throttle(last_mouse_time, current_time) then
    last_mouse_time = current_time
    log_input("mouse_input", window, pane)
  end
  return false  -- イベントを他のハンドラに渡す
end)

-- 必ず何か（テーブルでも空テーブルでもOK）をreturn
return {}

