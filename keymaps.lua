local wezterm = require("wezterm")
local act = wezterm.action

return {
  keys = {
    -----------------------------------------------
    --- 1. Basics
    -----------------------------------------------
    -- Show the command palette
    { key = "p", mods = "SUPER", action = act.ActivateCommandPalette },
    -- Toggle full screen (restored temporarily, to get out of full screen)
    { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
    -- Move the cursor by word
    { key = 'LeftArrow', mods = 'OPT', action = act.SendKey { key = "b", mods = "META" }, },
    { key = 'RightArrow', mods = 'OPT', action = act.SendKey { key = "f", mods = "META" }, },
    -- Alt+k scrolls up one line
    {
      key = 'k',
      mods = 'ALT',
      action = wezterm.action.ScrollByLine(-1),
    },
    -- Alt+j scrolls down one line
    {
      key = 'j',
      mods = 'ALT',
      action = wezterm.action.ScrollByLine(1),
    },
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\n') },
    -- Stop Ctrl+J from sending a newline (leftover from when it was the leader key)
    { key = 'j', mods = 'CTRL', action = act.Nop },
    -- Alt + t : Claude Thinking Mode Toggle
    { key = 't', mods = 'ALT', action = wezterm.action.SendKey { key = 't', mods = 'ALT', }, },
    -----------------------------------------------
    --- 2. Workspaces
    -----------------------------------------------
    {
      -- Show the workspace selector
      key = "w",
      mods = "LEADER",
      action = wezterm.action_callback(function(win, pane)
        require("workspaces").show_selector(win, pane)
      end),
    },
    -----------------------------------------------
    --- Tabs
    -----------------------------------------------
    -- Switch tabs
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
    { key = "l", mods = "SUPER", action = act.ActivateTabRelative(1) },
    { key = "h", mods = "SUPER", action = act.ActivateTabRelative(-1) },
    -- Reorder tabs
    { key = "{", mods = "LEADER", action = act({ MoveTabRelative = -1 }) },
    -- New tab
    { key = "t", mods = "SUPER", action = act({ SpawnTab = "CurrentPaneDomain" }) },
    -- Close tab
    { key = "w", mods = "SUPER", action = act({ CloseCurrentTab = { confirm = true } }) },
    { key = "}", mods = "LEADER", action = act({ MoveTabRelative = 1 }) },
    -- Rename the tab manually (empty input returns to automatic naming)
    {
      key = "r",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "タブ名 (空でリセット)",
        action = wezterm.action_callback(function(win, _pane, line)
          if line then
            win:active_tab():set_title(line)
          end
        end),
      }),
    },

    -----------------------------------------------
    --- Multiplexer
    -----------------------------------------------
    -- Copy mode
    -- { key = 'X', mods = 'LEADER', action = act.ActivateKeyTable{ name = 'copy_mode', one_shot =false }, },
    { key = "Space", mods = "LEADER", action = act.ActivateCopyMode },
    -- Copy
    { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
    -- Paste
    { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

    -- Split panes: leader + - / v
    { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- Close pane: leader + x
    { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
    -- Move between panes: leader + h/l/k/j
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    -- Select a pane
    { key = "[", mods = "CTRL|SHIFT", action = act.PaneSelect },
    -- Show only the current pane (zoom)
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    -- Move the current tab left/right
    -- Move once, then enter move_tab so further H/L presses keep moving the tab
    { key = 'H', mods = 'LEADER', action = act.Multiple({
      act.MoveTabRelative(-1),
      act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 1000, until_unknown = true }),
    }) },
    { key = 'L', mods = 'LEADER', action = act.Multiple({
      act.MoveTabRelative(1),
      act.ActivateKeyTable({ name = "move_tab", one_shot = false, timeout_milliseconds = 1000, until_unknown = true }),
    }) },
    -- Resize pane
    { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize { 'Down', 5 }, },
    { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 5 } },

    -----------------------------------------------
    --- Switching
    -----------------------------------------------
    -- Change font size
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    -- Reset font size
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    -- Switch tabs: Cmd + number
    { key = "1", mods = "SUPER", action = act.ActivateTab(0) },
    { key = "2", mods = "SUPER", action = act.ActivateTab(1) },
    { key = "3", mods = "SUPER", action = act.ActivateTab(2) },
    { key = "4", mods = "SUPER", action = act.ActivateTab(3) },
    { key = "5", mods = "SUPER", action = act.ActivateTab(4) },
    { key = "6", mods = "SUPER", action = act.ActivateTab(5) },
    { key = "7", mods = "SUPER", action = act.ActivateTab(6) },
    { key = "8", mods = "SUPER", action = act.ActivateTab(7) },
    { key = "9", mods = "SUPER", action = act.ActivateTab(-1) },

    -- Reload the config
    { key = "r", mods = "SUPER", action = act.ReloadConfiguration },
    -- Enter the pane-resize key table: leader + s
    { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

    -- Delete to the start of the line
    {
      key = 'Backspace',
      mods = 'SUPER',
      action = wezterm.action({
        SendString = "\x15"
      }) -- Ctrl+U
    },
    -- Cmd + Left -> start of line (Ctrl+A)
    {
      key = 'LeftArrow',
      mods = 'SUPER',
      action = wezterm.action.SendString('\x01'),
    },
    -- Cmd + Right -> end of line (Ctrl+E)
    {
      key = 'RightArrow',
      mods = 'SUPER',
      action = wezterm.action.SendString('\x05'),
    },
  },
  -- Key tables
  -- https://wezfurlong.org/wezterm/config/key-tables.html
  key_tables = {
    -- Repeated tab moves after leader + H/L
    move_tab = {
      { key = "H", action = act.MoveTabRelative(-1) },
      { key = "L", action = act.MoveTabRelative(1) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter", action = "PopKeyTable" },
    },
    -- Resize panes: leader + s
    resize_pane = {
      { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

      -- Leave the mode with Enter
      { key = "Enter", action = "PopKeyTable" },
    },
    activate_pane = {
      { key = "h", action = act.ActivatePaneDirection("Left") },
      { key = "l", action = act.ActivatePaneDirection("Right") },
      { key = "k", action = act.ActivatePaneDirection("Up") },
      { key = "j", action = act.ActivatePaneDirection("Down") },
    },
    -- Copy mode: leader + Space
    copy_mode = {
      -- Movement
      { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
      { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
      { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
      { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
      -- Start / end of the line content
      { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
      { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
      -- Start of the line
      { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
      { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
      { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
      --
      { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
      -- Move by word
      { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
      { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
      { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
      -- Jump to a character: t / f / T / F
      { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
      { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
      { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
      { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
      -- To the bottom
      { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
      -- To the top
      { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
      -- Viewport top / bottom / middle
      { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
      { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
      { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
      -- Scroll
      { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
      { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
      { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
      { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },

      -- Selection modes
      { key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
      { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
      { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
      -- Copy
      { key = "y", mods = "NONE", action = act.CopyTo("Clipboard") },

      -- Leave copy mode
      {
        key = "Enter",
        mods = "NONE",
        action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
      },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
      { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
      { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    },
  },
}

