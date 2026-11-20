local wezterm = require("wezterm")
local act = wezterm.action

-- Shortcut list shown as a fuzzy-searchable overlay. It reads the same sections
-- keymaps.lua builds the bindings from, so the list cannot drift from the bindings.
-- Only entries with `desc` are listed. Choosing a single global shortcut runs it;
-- family rows (`label`) and key table entries are listed for reference only.
local M = {}

local MOD_ORDER = { "LEADER", "CTRL", "ALT", "SHIFT", "SUPER" }
local MOD_ALIASES = { CMD = "SUPER", OPT = "ALT", META = "ALT" }
local MOD_LABELS = { LEADER = "Leader", CTRL = "Ctrl", ALT = "Opt", SHIFT = "Shift", SUPER = "Cmd" }
local KEY_LABELS = {
  LeftArrow = "←",
  RightArrow = "→",
  UpArrow = "↑",
  DownArrow = "↓",
}

local function key_label(entry)
  local present = {}
  for mod in (entry.mods or "NONE"):gmatch("[^|]+") do
    present[MOD_ALIASES[mod] or mod] = true
  end
  local parts = {}
  for _, mod in ipairs(MOD_ORDER) do
    if present[mod] then
      table.insert(parts, MOD_LABELS[mod])
    end
  end
  local key = KEY_LABELS[entry.key] or entry.key
  -- Show letters the way the keycap reads; an upper-case key in the config means Shift.
  if key:match("^%l$") then
    key = key:upper()
  elseif key:match("^%u$") then
    key = "Shift+" .. key
  end
  table.insert(parts, key)
  return table.concat(parts, "+")
end

local function pad(text, width)
  return text .. string.rep(" ", width - wezterm.column_width(text))
end

-- rows: { section, key, desc, action? }; action is set only when choosing the row runs it.
local function collect_rows(sections, key_tables)
  local rows = {}
  local function add(title, entries, runnable)
    for _, entry in ipairs(entries) do
      if entry.desc then
        table.insert(rows, {
          section = title,
          key = entry.label or key_label(entry),
          desc = entry.desc,
          action = runnable and not entry.label and entry.action or nil,
        })
      end
    end
  end
  for _, section in ipairs(sections) do
    add(section.title, section.keys, true)
  end
  for _, table_section in ipairs(key_tables) do
    add(table_section.title, table_section.keys, false)
  end
  return rows
end

function M.show(window, pane, sections, key_tables, leader)
  local rows = collect_rows(sections, key_tables)

  local section_width, key_width = 0, 0
  for _, row in ipairs(rows) do
    section_width = math.max(section_width, wezterm.column_width(row.section))
    key_width = math.max(key_width, wezterm.column_width(row.key))
  end

  local choices = {}
  for i, row in ipairs(rows) do
    table.insert(choices, {
      id = tostring(i),
      label = wezterm.format({
        { Foreground = { AnsiColor = "Grey" } },
        { Text = pad(row.section, section_width) .. "  " },
        { Foreground = { AnsiColor = "Aqua" } },
        { Attribute = { Intensity = "Bold" } },
        { Text = pad(row.key, key_width) },
        "ResetAttributes",
        { Text = "  " .. row.desc },
      }),
    })
  end

  window:perform_action(
    act.InputSelector({
      title = "Shortcuts",
      choices = choices,
      fuzzy = true,
      fuzzy_description = "ショートカット一覧 (Leader = " .. key_label(leader) .. ", Enter で実行, Esc で閉じる): ",
      action = wezterm.action_callback(function(inner_window, inner_pane, id)
        local row = id and rows[tonumber(id)]
        if row and row.action then
          inner_window:perform_action(row.action, inner_pane)
        end
      end),
    }),
    pane
  )
end

return M
