local wezterm = require('wezterm')
local mux = wezterm.mux

local M = {}

local function load_config()
  local home = os.getenv("HOME")
  local config_file = home .. "/.config/wezterm/workspaces/workspaces.json"

  local f = io.open(config_file, "r")
  if not f then
    wezterm.log_error("Failed to open config file: " .. config_file)
    return nil
  end

  local content = f:read("*all")
  f:close()

  local ok, config = pcall(function()
    return wezterm.json_parse(content)
  end)

  if not ok then
    wezterm.log_error("Failed to parse JSON config: " .. tostring(config))
    return nil
  end

  return config
end

function M.setup()
  local config = load_config()
  if not config then
    wezterm.log_error("Failed to load workspace config")
    return
  end

  wezterm.on('gui-startup', function(cmd)
    local profile = os.getenv("WEZTERM_PROFILE")

    -- profileが未設定の場合は空ウィンドウのみ
    if not profile or profile == "" then
      mux.spawn_window {}
      return
    end

    -- groupsから該当profileのworkspace一覧を取得
    if not config.groups or not config.groups[profile] then
      wezterm.log_error("No group found for profile: " .. profile)
      mux.spawn_window {}
      return
    end

    local workspaces = config.groups[profile]
    if #workspaces == 0 then
      wezterm.log_error("Empty workspace list for profile: " .. profile)
      mux.spawn_window {}
      return
    end

    -- 最初のワークスペースのみ同期作成
    local first_ws = workspaces[1]
    local first_tab, first_pane, window = mux.spawn_window {
      workspace = first_ws.name,
      cwd = first_ws.directory,
    }

    -- 最初のワークスペースの残りタブ作成
    local tabs = first_ws.tabs or 3
    for i = 2, tabs do
      window:spawn_tab { cwd = first_ws.directory }
    end

    -- 最初のタブをアクティブにする
    first_tab:activate()

    -- 残りのワークスペースを非同期作成（2つ以上ある場合のみ）
    if #workspaces > 1 then
      local sock = os.getenv("WEZTERM_UNIX_SOCKET")
      if sock then
        local home = os.getenv("HOME")
        local script = home .. "/.config/wezterm/workspaces/setup.sh"
        wezterm.background_child_process({ script, sock, profile })
      end
    end
  end)
end

return M
