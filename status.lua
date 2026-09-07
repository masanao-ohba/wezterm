local wezterm = require("wezterm")
local workspaces = require("workspaces")

-- 左上は「確認しに行く」静的な情報 (ワークスペース名・日時)、
-- 右上は作業中に変化する状態 (モード) を置く。
-- 隣り合うブロックは背景の明度を反転させ、境界が区切りグリフだけに
-- 依存しないようにする。バー地色 (中明度) に接する側を暗くする。
local BAR = "#332a57"
local WORKSPACE = { bg = "#c4b4f7", fg = "#1a1030" }
local DATETIME = { bg = "#0d0a18", fg = "#c9c2e8" }
local MODE = {
  normal_mode = { bg = "#00bfff", fg = "#332a57" },
  copy_mode = { bg = "#fffa6a", fg = "#332a57" },
  search_mode = { bg = "#00fbac", fg = "#332a57" },
}

-- ワークスペース名と日時の境界。上側が左隣の色、下側が右隣の色になる。
-- U+E0C0 以降 (炎・波形・台形など) はフォント由来で送り幅がセル幅と一致せず
-- 崩れる。wezterm が自前で描く U+E0B0〜U+E0BE から選ぶこと。
local SECTION_SEPARATOR = wezterm.nerdfonts.pl_left_hard_divider -- U+E0B0

local WEEKDAYS = { "日", "月", "火", "水", "木", "金", "土" }

local function active_mode(window)
  local key_table = window:active_key_table()
  if key_table and key_table:find("_mode$") then
    return key_table
  end
  return "normal_mode"
end

local function current_datetime()
  local now = wezterm.time.now()
  local weekday = WEEKDAYS[tonumber(now:format("%w")) + 1]
  return wezterm.nerdfonts.md_calendar_clock
    .. " "
    .. now:format("%m/%d(")
    .. weekday
    .. now:format(") %H:%M")
end

-- 状態はすべてこのハンドラ内のローカルに閉じること。モジュール変数に持たせると、
-- 複数ウィンドウの update-status が入れ子に実行された際に互いの値を上書きする。
wezterm.on("update-status", function(window)
  local elements = {}

  local function push(background, foreground, text, intensity)
    table.insert(elements, { Background = { Color = background } })
    table.insert(elements, { Foreground = { Color = foreground } })
    if intensity then
      table.insert(elements, { Attribute = { Intensity = intensity } })
    end
    table.insert(elements, { Text = text })
  end

  local workspace = workspaces.get_label(window:window_id()) or ""
  if workspace ~= "" then
    push(WORKSPACE.bg, WORKSPACE.fg, "  " .. workspace .. "  ", "Bold")
    push(DATETIME.bg, WORKSPACE.bg, SECTION_SEPARATOR)
  end
  push(DATETIME.bg, DATETIME.fg, "  " .. current_datetime() .. "  ", "Normal")

  -- 日時の右端は区切りを置かず垂直に切る。タブとの間に地色の余白だけ入れる。
  push(BAR, BAR, " ")

  window:set_left_status(wezterm.format(elements))

  -- モードの左端も区切りを置かず垂直に切る。
  local mode = active_mode(window)
  local colors = MODE[mode] or MODE.normal_mode
  window:set_right_status(wezterm.format({
    { Background = { Color = colors.bg } },
    { Foreground = { Color = colors.fg } },
    { Attribute = { Intensity = "Bold" } },
    { Text = "  " .. mode:gsub("_mode", ""):upper() .. "  " },
  }))
end)

return {}
