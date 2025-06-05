local wezterm = require 'wezterm'

wezterm.on('trigger-fzf-workspace-switcher', function(window, pane)
  local workspaces = wezterm.mux.get_workspace_names()
  local fzf_cmd = 'echo "' .. table.concat(workspaces, '\n') .. '" | fzf'

  window:perform_action(
    wezterm.action_callback(function(win, _)
      local success, stdout, _ = wezterm.run_child_process({ 'bash', '-c', fzf_cmd })
      if success and stdout then
        local selected = stdout:gsub('%s+$', '')  -- 改行削除
        if selected ~= '' then
          win:perform_action(wezterm.action.SwitchToWorkspace { name = selected }, pane)
        end
      end
    end),
    pane
  )
end)
