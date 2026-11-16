-- Colorscheme manager:
-- * remembers the last colorscheme (and background) and restores it on startup
-- * keeps a list of recently used colorschemes, shown first in the picker (<leader>uC)
-- * makes any colorscheme transparent when `vim.g.transparent_enabled` is set (<leader>uB)
-- State is stored in stdpath("state")/theme.json.
local M = {}

M.file = vim.fn.stdpath("state") .. "/theme.json"
M.default = "tokyonight-moon"
M.max_recent = 12

-- Highlight groups whose background is cleared when transparency is enabled
M.transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "NormalSB",
  "FloatBorder",
  "FloatTitle",
  "SignColumn",
  "FoldColumn",
  "LineNr",
  "CursorLineNr",
  "EndOfBuffer",
  "MsgArea",
  "StatusLine",
  "StatusLineNC",
  "TabLineFill",
  "WinBar",
  "WinBarNC",
}

-- True while the colorscheme picker is open, so previews don't end up in the recent list
M.previewing = false

---@class util.theme.State
---@field colorscheme string
---@field background "dark"|"light"
---@field recent string[]
---@field transparent boolean

---@return util.theme.State
function M.state()
  local state = {}
  local f = io.open(M.file, "r")
  if f then
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    state = ok and type(data) == "table" and data or {}
  end
  return vim.tbl_extend("keep", state, {
    colorscheme = M.default,
    background = "dark",
    recent = {},
    transparent = vim.g.transparent_enabled ~= false,
  })
end

---@param state util.theme.State
local function write(state)
  vim.fn.mkdir(vim.fs.dirname(M.file), "p")
  local f = io.open(M.file, "w")
  if f then
    f:write(vim.json.encode(state))
    f:close()
  end
end

---@param name string
function M.remember(name)
  local state = M.state()
  state.colorscheme = name
  state.background = vim.o.background
  local recent = { name }
  for _, other in ipairs(state.recent) do
    if other ~= name and #recent < M.max_recent then
      recent[#recent + 1] = other
    end
  end
  state.recent = recent
  write(state)
end

---@param name string
function M.forget(name)
  local state = M.state()
  state.recent = vim.tbl_filter(function(other)
    return other ~= name
  end, state.recent)
  write(state)
end

local function clear_backgrounds()
  for _, group in ipairs(M.transparent_groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    hl.bg, hl.ctermbg = nil, nil
    vim.api.nvim_set_hl(0, group, hl)
  end
end

-- tokyonight has its own (more thorough) transparency, keep it in sync with ours
local function sync_plugins(on)
  local tokyonight = package.loaded["tokyonight.config"]
  if tokyonight and tokyonight.options then
    tokyonight.options.transparent = on
    tokyonight.options.styles.sidebars = on and "transparent" or "dark"
    tokyonight.options.styles.floats = on and "transparent" or "dark"
  end
end

---@param on boolean
function M.set_transparent(on)
  vim.g.transparent_enabled = on
  local state = M.state()
  state.transparent = on
  write(state)
  sync_plugins(on)
  -- re-apply the colorscheme so backgrounds come back when turning it off
  vim.cmd.colorscheme(vim.g.colors_name or M.default)
end

--- Switch back to the previously used colorscheme
function M.previous()
  local prev = M.state().recent[2]
  if prev then
    vim.cmd.colorscheme(prev)
    vim.notify("Colorscheme: " .. prev)
  else
    vim.notify("No previous colorscheme", vim.log.levels.WARN)
  end
end

local did_setup = false
function M.setup()
  if did_setup then
    return
  end
  did_setup = true
  local group = vim.api.nvim_create_augroup("util_theme", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function(ev)
      if vim.g.transparent_enabled then
        clear_backgrounds()
      end
      if not M.previewing then
        M.remember(ev.match)
      end
    end,
  })
end

--- Restore the last used colorscheme. Used as LazyVim's `colorscheme` option.
function M.load()
  M.setup()
  local state = M.state()
  vim.g.transparent_enabled = state.transparent
  vim.o.background = state.background
  if not pcall(vim.cmd.colorscheme, state.colorscheme) then
    vim.notify("Colorscheme `" .. state.colorscheme .. "` not found, using " .. M.default, vim.log.levels.WARN)
    vim.cmd.colorscheme(M.default)
  end
end

--- Snacks picker source for colorschemes: recent ones first, then plugin ones, then the builtin ones.
---@type snacks.picker.Config
M.picker = {
  finder = function()
    local rank = {} ---@type table<string, number>
    for i, name in ipairs(M.state().recent) do
      rank[name] = i
    end
    local runtime = vim.fs.normalize(vim.env.VIMRUNTIME)
    local items, seen = {}, {} ---@type snacks.picker.finder.Item[], table<string, boolean>
    for _, item in ipairs(require("snacks.picker.source.vim").colorschemes()) do
      if not seen[item.text] then
        seen[item.text] = true
        item.recent = rank[item.text]
        item.builtin = vim.fs.normalize(item.file):sub(1, #runtime) == runtime
        items[#items + 1] = item
      end
    end
    table.sort(items, function(a, b)
      if a.recent or b.recent then
        return (a.recent or math.huge) < (b.recent or math.huge)
      end
      if a.builtin ~= b.builtin then
        return b.builtin
      end
      return a.text < b.text
    end)
    return items
  end,
  format = function(item)
    return {
      { item.recent and "󰋚 " or "  ", "SnacksPickerSpecial" },
      { item.text },
      { item.builtin and "  builtin" or "", "Comment" },
    }
  end,
  on_show = function()
    M.previewing = true
  end,
  on_close = function()
    M.previewing = false
  end,
  confirm = function(picker, item)
    picker.preview.state.colorscheme = nil -- don't restore the original colorscheme on close
    picker:close()
    if item then
      vim.schedule(function()
        M.previewing = false
        vim.cmd.colorscheme(item.text)
      end)
    end
  end,
  actions = {
    colorscheme_forget = function(picker, item)
      if item and item.recent then
        M.forget(item.text)
        picker:find()
      end
    end,
  },
  win = {
    input = {
      keys = {
        ["<c-x>"] = { "colorscheme_forget", mode = { "n", "i" }, desc = "Remove from recent" },
      },
    },
  },
}

return M
