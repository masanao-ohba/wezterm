local wezterm = require("wezterm")
local act = wezterm.action
local cheatsheet = require("cheatsheet")
local pane_dim = require("pane_dim")

local M = {}

M.leader = { key = "f", mods = "CMD", timeout_milliseconds = 2000 }

-- The shortcut list (LEADER + ?) shows only bindings that carry `desc`; leave it off
-- bindings that are self-evident (Cmd+C, Cmd+1..9) or rarely used.
-- A binding that stands for a family of keys also carries `label`, the key text of
-- that single row (e.g. "Leader+H/J/K/L"), and the other members carry no `desc`.
-- `desc` and `label` are not wezterm fields, so M.keys / M.key_tables strip them
-- before the bindings reach the config.
local sections
local key_table_sections
local listed_key_tables

sections = {
  {
    title = "基本",
    keys = {
      { key = "?", mods = "LEADER", desc = "ショートカット一覧を表示", action = wezterm.action_callback(function(win, pane)
        cheatsheet.show(win, pane, sections, listed_key_tables, M.leader)
      end) },
      { key = "p", mods = "SUPER", desc = "コマンドパレット", action = act.ActivateCommandPalette },
      -- Restored temporarily, to get out of full screen
      { key = "Enter", mods = "ALT", desc = "フルスクリーン切り替え", action = act.ToggleFullScreen },
      { key = "r", mods = "SUPER", desc = "設定を再読み込み", action = act.ReloadConfiguration },
      { key = "+", mods = "CTRL", label = "Ctrl++/-/0", desc = "フォントサイズ 拡大/縮小/リセット", action = act.IncreaseFontSize },
      { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
      { key = "0", mods = "CTRL", action = act.ResetFontSize },
      { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
      { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
      { key = "Space", mods = "LEADER", desc = "コピーモード", action = act.ActivateCopyMode },
      -- { key = 'X', mods = 'LEADER', action = act.ActivateKeyTable{ name = 'copy_mode', one_shot =false }, },
    },
  },
  {
    title = "スクロール",
    keys = {
      { key = "LeftArrow", mods = "OPT", action = act.SendKey({ key = "b", mods = "META" }) },
      { key = "RightArrow", mods = "OPT", action = act.SendKey({ key = "f", mods = "META" }) },
      -- Ctrl+A / Ctrl+E
      { key = "LeftArrow", mods = "SUPER", action = act.SendString("\x01") },
      { key = "RightArrow", mods = "SUPER", action = act.SendString("\x05") },
      -- Ctrl+U
      { key = "Backspace", mods = "SUPER", action = act.SendString("\x15") },
      { key = "Enter", mods = "SHIFT", action = act.SendString("\n") },
      { key = "k", mods = "ALT", label = "Opt+K/J", desc = "1行ずつ上/下へスクロール", action = act.ScrollByLine(-1) },
      { key = "j", mods = "ALT", action = act.ScrollByLine(1) },
      -- Leftover from when Ctrl+J was the leader key: stop it from sending a newline
      { key = "j", mods = "CTRL", action = act.Nop },
      -- Claude Thinking Mode toggle
      { key = "t", mods = "ALT", action = act.SendKey({ key = "t", mods = "ALT" }) },
    },
  },
  {
    title = "ワークスペース",
    keys = {
      { key = "w", mods = "LEADER", desc = "ワークスペースを選択", action = wezterm.action_callback(function(win, pane)
        require("workspaces").show_selector(win, pane)
      end) },
    },
  },
  {
    title = "タブ",
    keys = {
      { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
      { key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
      { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
      { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
      { key = "h", mods = "SUPER", label = "Cmd+H/L", desc = "前/次のタブ", action = act.ActivateTabRelative(-1) },
      { key = "l", mods = "SUPER", action = act.ActivateTabRelative(1) },
      { key = "1", mods = "SUPER", action = act.ActivateTab(0) },
      { key = "2", mods = "SUPER", action = act.ActivateTab(1) },
      { key = "3", mods = "SUPER", action = act.ActivateTab(2) },
      { key = "4", mods = "SUPER", action = act.ActivateTab(3) },
      { key = "5", mods = "SUPER", action = act.ActivateTab(4) },
      { key = "6", mods = "SUPER", action = act.ActivateTab(5) },
      { key = "7", mods = "SUPER", action = act.ActivateTab(6) },
      { key = "8", mods = "SUPER", action = act.ActivateTab(7) },
      { key = "9", mods = "SUPER", action = act.ActivateTab(-1) },
      { key = "{", mods = "LEADER", action = act.MoveTabRelative(-1) },
      { key = "}", mods = "LEADER", action = act.MoveTabRelative(1) },
      -- Move once, then enter move_tab so further H/L presses keep moving the tab
      { key = "H", mods = "LEADER", label = "Leader+Shift+H/L", desc = "タブを左/右へ移動 (続けて H/L で連続移動)", action = act.Multiple({
        act.MoveTabRelative(-1),
        act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 1000, until_unknown = true }),
      }) },
      { key = "L", mods = "LEADER", action = act.Multiple({
        act.MoveTabRelative(1),
        act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 1000, until_unknown = true }),
      }) },
      { key = "r", mods = "LEADER", desc = "タブ名を変更 (空でリセット)", action = act.PromptInputLine({
        description = "タブ名 (空でリセット)",
        action = wezterm.action_callback(function(win, _pane, line)
          if line then
            win:active_tab():set_title(line)
          end
        end),
      }) },
    },
  },
  {
    title = "ペイン",
    keys = {
      { key = "-", mods = "LEADER", desc = "上下に分割", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
      { key = "v", mods = "LEADER", desc = "左右に分割", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
      { key = "x", mods = "LEADER", desc = "ペインを閉じる", action = act.CloseCurrentPane({ confirm = true }) },
      { key = "h", mods = "LEADER", label = "Leader+H/J/K/L", desc = "隣のペインへ移動", action = act.ActivatePaneDirection("Left") },
      { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
      { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
      { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
      { key = "[", mods = "CTRL|SHIFT", desc = "ペインを番号で選択", action = act.PaneSelect },
      { key = "z", mods = "LEADER", desc = "ペインのズーム切り替え", action = act.TogglePaneZoomState },
      { key = "d", mods = "LEADER", desc = "非アクティブペインの減光を切り替え", action = wezterm.action_callback(function(win, _pane)
        pane_dim.toggle(win)
      end) },
      { key = "J", mods = "LEADER", label = "Leader+Shift+J/K", desc = "ペインを下/上へ広げる (5)", action = act.AdjustPaneSize({ "Down", 5 }) },
      { key = "K", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
      { key = "s", mods = "LEADER", desc = "リサイズモード (H/J/K/L で 1 ずつ, Enter で終了)", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
    },
  },
}

-- Key tables (https://wezfurlong.org/wezterm/config/key-tables.html). Titled ones
-- are listed in the shortcut list.
key_table_sections = {
  -- Described by the Leader+Shift+H/L row
  {
    name = "move_tab",
    keys = {
      { key = "H", action = act.MoveTabRelative(-1) },
      { key = "L", action = act.MoveTabRelative(1) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter", action = "PopKeyTable" },
    },
  },
  -- Described by the Leader+S row
  {
    name = "resize_pane",
    keys = {
      { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
      { key = "Enter", action = "PopKeyTable" },
    },
  },
  {
    name = "copy_mode",
    title = "コピーモード",
    keys = {
      -- Movement, as in Vim
      { key = "h", mods = "NONE", label = "Vim の移動キー", desc = "hjkl, w/b/e, 0/^/$, g/G, f/t/F/T/;, H/M/L, Ctrl+B/F/D/U", action = act.CopyMode("MoveLeft") },
      { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
      { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
      { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
      { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
      { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
      { key = "o", mods = "NONE", label = "O / Shift+O", desc = "選択の反対端へ (Shift で水平方向のみ)", action = act.CopyMode("MoveToSelectionOtherEnd") },
      { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
      { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
      { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
      { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
      { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
      { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
      { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
      { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
      { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
      { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
      { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
      { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
      { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
      { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
      { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
      { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
      { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
      { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
      -- Selection
      { key = "Space", mods = "NONE", desc = "文字単位で選択開始", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
      { key = "V", mods = "NONE", desc = "行選択", action = act.CopyMode({ SetSelectionMode = "Line" }) },
      { key = "v", mods = "CTRL", desc = "矩形選択", action = act.CopyMode({ SetSelectionMode = "Block" }) },
      -- Copy / leave
      { key = "y", mods = "NONE", desc = "コピー (モードは継続)", action = act.CopyTo("Clipboard") },
      { key = "Enter", mods = "NONE", desc = "コピーして終了", action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },
      { key = "Escape", mods = "NONE", label = "Esc / Q / Ctrl+C", desc = "コピーせず終了", action = act.CopyMode("Close") },
      { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
      { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    },
  },
  -- Not activated by any binding
  {
    name = "activate_pane",
    keys = {
      { key = "h", action = act.ActivatePaneDirection("Left") },
      { key = "l", action = act.ActivatePaneDirection("Right") },
      { key = "k", action = act.ActivatePaneDirection("Up") },
      { key = "j", action = act.ActivatePaneDirection("Down") },
    },
  },
}

local function to_wezterm_keys(entries)
  local keys = {}
  for _, entry in ipairs(entries) do
    table.insert(keys, { key = entry.key, mods = entry.mods, action = entry.action })
  end
  return keys
end

M.keys = {}
for _, section in ipairs(sections) do
  for _, key in ipairs(to_wezterm_keys(section.keys)) do
    table.insert(M.keys, key)
  end
end

M.key_tables = {}
for _, table_section in ipairs(key_table_sections) do
  M.key_tables[table_section.name] = to_wezterm_keys(table_section.keys)
end

listed_key_tables = {}
for _, table_section in ipairs(key_table_sections) do
  if table_section.title then
    table.insert(listed_key_tables, table_section)
  end
end

return M
