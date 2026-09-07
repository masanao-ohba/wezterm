local wezterm = require("wezterm")

-- タブ名の決定規則。呼び出し側の型に依存しないよう、引数は文字列だけを受け取る。
local M = {}

M.MAX_WIDTH = 23

-- シェルが名乗るだけのタイトルは識別に使えないので cwd に落とす
local SHELL_TITLES = { zsh = true, bash = true, sh = true, fish = true }

local function basename(path)
  if not path or path == "" then
    return nil
  end
  return path:gsub("/+$", ""):match("([^/]+)$")
end

-- 手動命名 > パネルタイトル > cwd のベース名 の順に採用する。
-- tab:set_title() で付けた名前は自動命名の材料とは別に保持されるため、
-- 手動命名が自動更新で潰れることはない。
function M.resolve(explicit, pane_title, cwd_path)
  if explicit and explicit ~= "" then
    return explicit
  end
  if pane_title and pane_title ~= "" and not SHELL_TITLES[pane_title] then
    return pane_title
  end
  return basename(cwd_path) or pane_title or ""
end

-- 先頭を残して省略する。要約は先頭のほうが識別に効くため。
function M.truncate(text)
  if wezterm.column_width(text) <= M.MAX_WIDTH then
    return text
  end
  return wezterm.truncate_right(text, M.MAX_WIDTH - 1) .. "…"
end

-- タブに表示する文字列。左右のキャップは含まない。
function M.label(number, explicit, pane_title, cwd_path)
  return " " .. number .. ": " .. M.truncate(M.resolve(explicit, pane_title, cwd_path)) .. " "
end

return M
