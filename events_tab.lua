local wezterm = require("wezterm")
local colors = require("colors")
local status = require("status")
local tab_title = require("tab_title")

-- 台形 (下底が広い) にするため左右のキャップを鏡像にする。
-- どちらもタブ色でグリフを描き、地色をバー色にする。
local CAP_LEFT = wezterm.nerdfonts.ple_lower_right_triangle -- U+E0BA
local CAP_RIGHT = wezterm.nerdfonts.ple_lower_left_triangle -- U+E0B8
local CAP_CELLS = 2

-- タブ名がこれ以下になるくらいなら、名前の断片が残っていたほうが選びやすい。
local MIN_WIDTH = 6

-- タブバー全体で使える桁数。fancy タブバーは window_frame.font_size で描かれる
-- 一方、PaneInformation の桁は本文フォントのものなので、サイズ比で概算する。
-- フォントの幅比までは取れないため 0.9 を掛けて少なめに見積もる。多く見積もると
-- タブが右のモード表示に重なるため、誤差は必ず狭い側へ倒すこと。
local function tabbar_cells(panes, config)
  local cols = 0
  for _, pane in ipairs(panes) do
    cols = math.max(cols, pane.left + pane.width)
  end
  if cols == 0 then
    return nil
  end
  local frame_size = (config.window_frame and config.window_frame.font_size) or config.font_size
  return math.floor(cols * (config.font_size / frame_size) * 0.9)
end

-- 1タブあたりのタイトル上限桁。ウィンドウ幅が取れないときは wezterm が渡す
-- max_width と MAX_WIDTH だけで決める。
local function title_width(tab, tabs, panes, config, max_width)
  local overhead = CAP_CELLS + tab_title.overhead(tab.tab_index + 1)
  local width = math.min(tab_title.MAX_WIDTH, max_width - overhead)

  local cells = tabbar_cells(panes, config)
  if cells then
    local room = cells - status.left_cells(tab.window_id) - status.right_cells()
    width = math.min(width, math.floor(room / math.max(#tabs, 1)) - overhead)
  end

  return math.max(MIN_WIDTH, width)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local tab_colors = tab.is_active and colors.TAB_ACTIVE or colors.TAB_INACTIVE
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  local label = tab_title.label(
    tab.tab_index + 1,
    tab.tab_title,
    pane.title,
    cwd and cwd.file_path or nil,
    title_width(tab, tabs, panes, config, max_width)
  )

  return {
    { Background = { Color = colors.BAR } },
    { Foreground = { Color = tab_colors.bg } },
    { Text = CAP_LEFT },

    { Background = { Color = tab_colors.bg } },
    { Foreground = { Color = tab_colors.fg } },
    { Text = label },

    { Background = { Color = colors.BAR } },
    { Foreground = { Color = tab_colors.bg } },
    { Text = CAP_RIGHT },
  }
end)
