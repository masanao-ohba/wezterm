local wezterm = require('wezterm')
local act = wezterm.action
local mux = wezterm.mux

local M = {}

local window_registry = {}

-- Helpers

local function defer(fn)
  wezterm.time.call_after(0.1, fn)
end

local function get_mux_window(window_id)
  for _, w in ipairs(mux.all_windows()) do
    if w:window_id() == window_id then return w end
  end
  return nil
end

local function load_config()
  local f = io.open(os.getenv("HOME") .. "/.config/wezterm/workspaces/workspaces.json", "r")
  if not f then return nil end
  local content = f:read("*all")
  f:close()
  local ok, config = pcall(wezterm.json_parse, content)
  return ok and config or nil
end

local function find_window_by_name(name)
  for wid, info in pairs(window_registry) do
    if info.name ~= name then goto continue end
    local w = get_mux_window(wid)
    if w then return w, info end
    window_registry[wid] = nil
    ::continue::
  end
  return nil
end

local function is_opened(name)
  return find_window_by_name(name) ~= nil
end

local function find_repo(repos, name)
  for _, repo in ipairs(repos) do
    if repo.name == name then return repo end
  end
  return nil
end

local function register_window(wid, group_name, repo_config)
  window_registry[wid] = {
    group = group_name,
    name = repo_config.name,
    directory = repo_config.directory,
  }
end

local function spawn_tabs(window, directory, count)
  for i = 2, (count or 3) do
    window:spawn_tab { cwd = directory }
  end
end

-- Selectors

local function build_stage2(config, group_name, on_select_new, on_select_opened)
  local repos = config.groups[group_name]
  if not repos then return nil end

  local choices = {}
  for _, repo in ipairs(repos) do
    table.insert(choices, {
      id = repo.name,
      label = is_opened(repo.name) and ("* " .. repo.name) or repo.name,
    })
  end

  return act.InputSelector {
    action = wezterm.action_callback(function(win, pane, id)
      if not id then return end
      local repo_config = find_repo(repos, id)
      if not repo_config then return end
      local handler = is_opened(id) and on_select_opened or on_select_new
      handler(win, pane, repo_config, group_name)
    end),
    title = "Select repo in [" .. group_name .. "]",
    choices = choices,
    fuzzy = true,
    fuzzy_description = group_name .. " > ",
  }
end

local function build_stage1(config, on_select_new, on_select_opened)
  local choices = {}

  for group_name, _ in pairs(config.groups) do
    table.insert(choices, {
      id = "group:" .. group_name,
      label = "[" .. group_name .. "]",
    })
  end

  for wid, info in pairs(window_registry) do
    if get_mux_window(wid) then
      table.insert(choices, {
        id = "window:" .. info.name,
        label = "> " .. info.name,
      })
    else
      window_registry[wid] = nil
    end
  end

  local handlers = {
    group = function(win, pane, value)
      local stage2 = build_stage2(config, value, on_select_new, on_select_opened)
      if stage2 then win:perform_action(stage2, pane) end
    end,
    window = function(_win, _pane, value)
      defer(function()
        local w = find_window_by_name(value)
        if w then w:gui_window():focus() end
      end)
    end,
  }

  return act.InputSelector {
    action = wezterm.action_callback(function(win, pane, id)
      if not id then return end
      local kind, value = id:match("^(%w+):(.+)$")
      local handler = kind and handlers[kind]
      if handler then handler(win, pane, value) end
    end),
    title = "Select group or window",
    choices = choices,
    fuzzy = true,
    fuzzy_description = "Group / Window > ",
  }
end

-- Actions

local function focus_window(_win, _pane, repo_config)
  defer(function()
    local w = find_window_by_name(repo_config.name)
    if w then w:gui_window():focus() end
  end)
end

local function create_new_window(_win, _pane, repo_config, group_name)
  defer(function()
    local _, _, new_window = mux.spawn_window { cwd = repo_config.directory }
    spawn_tabs(new_window, repo_config.directory, repo_config.tabs)
    register_window(new_window:window_id(), group_name, repo_config)
  end)
end

-- Public

function M.get_label(window_id)
  local info = window_registry[window_id]
  return info and info.name or nil
end

function M.show_selector(win, pane)
  local config = load_config()
  if not config or not config.groups then return end
  win:perform_action(build_stage1(config, create_new_window, focus_window), pane)
end

function M.setup()
  wezterm.on('gui-startup', function()
    local config = load_config()
    if not config or not config.groups then
      mux.spawn_window {}
      return
    end

    local tab, pane, window = mux.spawn_window {}

    local function on_select_new(_, _, repo_config, group_name)
      defer(function()
        pane:send_text('cd ' .. repo_config.directory .. ' && clear\n')
        spawn_tabs(window, repo_config.directory, repo_config.tabs)
        tab:activate()
        register_window(window:window_id(), group_name, repo_config)
      end)
    end

    local stage1 = build_stage1(config, on_select_new, focus_window)
    window:gui_window():perform_action(stage1, pane)
  end)
end

return M
