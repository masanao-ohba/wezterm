local wezterm = require("wezterm")
local colors = require("colors")
local workspaces = require("workspaces")

-- 左右ステータスの描画。桁数の問い合わせ (left_cells / right_cells) も
-- ここが持つ。書式を変えたら桁数も一緒に変わるよう、両者は同じ組み立て関数を
-- 通すこと。events_tab.lua はこの桁数を引いてタブ幅を決めている。
local M = {}

-- ワークスペース名と日時の境界。上側が左隣の色、下側が右隣の色になる。
-- U+E0C0 以降 (炎・波形・台形など) はフォント由来で送り幅がセル幅と一致せず
-- 崩れる。wezterm が自前で描く U+E0B0〜U+E0BE から選ぶこと。
local SECTION_SEPARATOR = wezterm.nerdfonts.pl_left_hard_divider -- U+E0B0

-- チップの左右に入れる余白と、日時とタブの間に置く地色の余白。
local PAD = "  "
local GAP = " "

local WEEKDAYS = { "日", "月", "火", "水", "木", "金", "土" }

local function chip(text)
  return PAD .. text .. PAD
end

local function active_mode(window)
  local key_table = window:active_key_table()
  if key_table and key_table:find("_mode$") then
    return key_table
  end
  return "normal_mode"
end

local function mode_text(mode)
  return mode:gsub("_mode", ""):upper()
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

-- 左ステータスが専有する桁数。ワークスペース名は窓ごとに変わるので窓を受け取る。
function M.left_cells(window_id)
  local cells = wezterm.column_width(chip(current_datetime()) .. GAP)
  local workspace = workspaces.get_label(window_id) or ""
  if workspace ~= "" then
    cells = cells + wezterm.column_width(chip(workspace) .. SECTION_SEPARATOR)
  end
  return cells
end

-- 右ステータスが専有する桁数。モードは状態で変わるので最長のものを返す。
function M.right_cells()
  local cells = 0
  for mode in pairs(colors.MODE) do
    cells = math.max(cells, wezterm.column_width(chip(mode_text(mode))))
  end
  return cells
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
    push(colors.WORKSPACE.bg, colors.WORKSPACE.fg, chip(workspace), "Bold")
    push(colors.DATETIME.bg, colors.WORKSPACE.bg, SECTION_SEPARATOR)
  end
  push(colors.DATETIME.bg, colors.DATETIME.fg, chip(current_datetime()), "Normal")

  -- 日時の右端は区切りを置かず垂直に切る。タブとの間に地色の余白だけ入れる。
  push(colors.BAR, colors.BAR, GAP)

  window:set_left_status(wezterm.format(elements))

  -- モードの左端も区切りを置かず垂直に切る。
  local mode = active_mode(window)
  local mode_colors = colors.MODE[mode] or colors.MODE.normal_mode
  window:set_right_status(wezterm.format({
    { Background = { Color = mode_colors.bg } },
    { Foreground = { Color = mode_colors.fg } },
    { Attribute = { Intensity = "Bold" } },
    { Text = chip(mode_text(mode)) },
  }))
end)

return M
