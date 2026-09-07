local wezterm = require("wezterm")

-- タブ名の決定規則。呼び出し側の型に依存しないよう、引数は文字列だけを受け取る。
local M = {}

M.MAX_WIDTH = 23

-- タブ番号と左右の余白。label と overhead が同じ組み立てを通ることで、
-- 書式を変えたときに桁数の見積もりが取り残されないようにする。
local function prefix(number)
  return " " .. number .. ": "
end
local SUFFIX = " "

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
-- width は呼び出し側がウィンドウ幅から算出した上限。省略時は MAX_WIDTH。
function M.truncate(text, width)
  width = width or M.MAX_WIDTH
  if wezterm.column_width(text) <= width then
    return text
  end
  return wezterm.truncate_right(text, math.max(width - 1, 1)) .. "…"
end

-- タブに表示する文字列。左右のキャップは含まない。
function M.label(number, explicit, pane_title, cwd_path, width)
  return prefix(number) .. M.truncate(M.resolve(explicit, pane_title, cwd_path), width) .. SUFFIX
end

-- label がタブ名以外に使う桁数。番号が2桁になれば1桁増える。
function M.overhead(number)
  return wezterm.column_width(prefix(number) .. SUFFIX)
end

return M
