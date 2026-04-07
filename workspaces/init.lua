local wezterm = require('wezterm')
local act = wezterm.action
local mux = wezterm.mux

local M = {}

-- Window registry: window_id -> {group, name, directory}
local window_registry = {}

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

-- Find a registered window by name
local function find_window_by_name(name)
  for window_id, info in pairs(window_registry) do
    if info.name == name then
      for _, mux_window in ipairs(mux.all_windows()) do
        if mux_window:window_id() == window_id then
          return mux_window, info
        end
      end
      -- Window no longer exists, clean up registry
      window_registry[window_id] = nil
    end
  end
  return nil
end

-- Check if a repo name is already opened
local function is_opened(name)
  return find_window_by_name(name) ~= nil
end

-- Build Stage 2 InputSelector for a group
local function build_stage2(config, group_name, on_select_new, on_select_opened)
  local repos = config.groups[group_name]
  if not repos then return nil end

  local choices = {}
  for _, repo in ipairs(repos) do
    local label = repo.name
    if is_opened(repo.name) then
      label = "* " .. label
    end
    table.insert(choices, {
      id = repo.name,
      label = label,
    })
  end

  return act.InputSelector {
    action = wezterm.action_callback(function(win, pane, id, label)
      if not id and not label then
        wezterm.log_info("Repo selection canceled")
        return
      end

      -- Find the repo config
      local repo_config = nil
      for _, repo in ipairs(repos) do
        if repo.name == id then
          repo_config = repo
          break
        end
      end
      if not repo_config then return end

      if is_opened(id) then
        on_select_opened(win, pane, repo_config, group_name)
      else
        on_select_new(win, pane, repo_config, group_name)
      end
    end),
    title = "Select repo in [" .. group_name .. "]",
    choices = choices,
    fuzzy = true,
    fuzzy_description = group_name .. " > ",
  }
end

-- Build Stage 1 InputSelector
local function build_stage1(config, on_select_new, on_select_opened)
  local choices = {}

  -- Add group names
  for group_name, _ in pairs(config.groups) do
    table.insert(choices, {
      id = "group:" .. group_name,
      label = "[" .. group_name .. "]",
    })
  end

  -- Add already-opened windows
  for window_id, info in pairs(window_registry) do
    -- Verify window still exists
    local exists = false
    for _, mux_window in ipairs(mux.all_windows()) do
      if mux_window:window_id() == window_id then
        exists = true
        break
      end
    end
    if exists then
      table.insert(choices, {
        id = "window:" .. info.name,
        label = "> " .. info.name,
      })
    else
      window_registry[window_id] = nil
    end
  end

  return act.InputSelector {
    action = wezterm.action_callback(function(win, pane, id, label)
      if not id and not label then
        wezterm.log_info("Workspace selection canceled")
        return
      end

      if id:sub(1, 6) == "group:" then
        local group_name = id:sub(7)
        local stage2 = build_stage2(config, group_name, on_select_new, on_select_opened)
        if stage2 then
          win:perform_action(stage2, pane)
        end
      elseif id:sub(1, 7) == "window:" then
        local name = id:sub(8)
        local mux_window = find_window_by_name(name)
        if mux_window then
          mux_window:gui_window():focus()
        end
      end
    end),
    title = "Select group or window",
    choices = choices,
    fuzzy = true,
    fuzzy_description = "Group / Window > ",
  }
end

-- Focus an already-opened window
local function focus_window(_win, _pane, repo_config)
  local mux_window = find_window_by_name(repo_config.name)
  if mux_window then
    mux_window:gui_window():focus()
  end
end

-- Create a new Mux Window for a repo
local function create_new_window(_win, _pane, repo_config, group_name)
  local _, _, window = mux.spawn_window { cwd = repo_config.directory }
  local tabs = repo_config.tabs or 3
  for i = 2, tabs do
    window:spawn_tab { cwd = repo_config.directory }
  end
  window_registry[window:window_id()] = {
    group = group_name,
    name = repo_config.name,
    directory = repo_config.directory,
  }
end

function M.show_selector(win, pane)
  local config = load_config()
  if not config or not config.groups then
    wezterm.log_error("Failed to load workspace config for selector")
    return
  end

  local stage1 = build_stage1(config, create_new_window, focus_window)
  win:perform_action(stage1, pane)
end

function M.setup()
  wezterm.on('gui-startup', function(cmd)
    local config = load_config()
    if not config or not config.groups then
      wezterm.log_error("Failed to load workspace config")
      mux.spawn_window {}
      return
    end

    -- Create initial window (no cwd, no workspace)
    local tab, pane, window = mux.spawn_window {}

    -- Reuse-mode callbacks for startup
    local function on_select_new_startup(win, sel_pane, repo_config, group_name)
      -- Reuse the initial window: cd in the first pane
      pane:send_text('cd ' .. repo_config.directory .. ' && clear\n')

      -- Spawn remaining tabs
      local tabs = repo_config.tabs or 3
      for i = 2, tabs do
        window:spawn_tab { cwd = repo_config.directory }
      end
      tab:activate()

      -- Register the window
      window_registry[window:window_id()] = {
        group = group_name,
        name = repo_config.name,
        directory = repo_config.directory,
      }
    end

    local function on_select_opened_startup(_win, _pane, repo_config)
      -- At startup there are no opened windows yet, but handle gracefully
      focus_window(_win, _pane, repo_config)
    end

    local stage1 = build_stage1(config, on_select_new_startup, on_select_opened_startup)
    window:gui_window():perform_action(stage1, pane)
  end)
end

return M
