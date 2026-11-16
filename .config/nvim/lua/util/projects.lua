-- Remembers every project you work in, so the projects picker (<leader>fp) can list them.
-- A project is the root of any file you open (or of the cwd), detected with `M.markers`.
-- The list is stored in stdpath("data")/projects.json and shared between nvim instances.
local M = {}

M.file = vim.fn.stdpath("data") .. "/projects.json"

local function ext(...)
  local exts = { ... }
  return function(name)
    for _, e in ipairs(exts) do
      if name:sub(-#e) == e then
        return true
      end
    end
    return false
  end
end

-- Root markers, highest priority first: a git repo wins over a solution,
-- which wins over language manifests (so sub-projects don't show up separately).
M.markers = {
  ".git",
  ext(".sln", ".slnx"),
  { "Cargo.toml", "go.mod", "package.json", "pyproject.toml", "CMakeLists.txt", "Makefile", "lazy-lock.json" },
  ext(".csproj", ".fsproj"),
}

-- Directories that are never projects
local function ignored(dir)
  local home = vim.fs.normalize("~")
  if dir == home or dir == "/" then
    return true
  end
  for _, prefix in ipairs({
    vim.fn.stdpath("data"),
    vim.fn.stdpath("state"),
    vim.fn.stdpath("cache"),
    vim.env.VIMRUNTIME,
    "/tmp",
    "/usr",
    home .. "/.cargo",
    home .. "/.nuget",
    home .. "/go/pkg",
  }) do
    prefix = vim.fs.normalize(prefix)
    if dir == prefix or dir:sub(1, #prefix + 1) == prefix .. "/" then
      return true
    end
  end
  return false
end

---@return table<string, number> project dir -> last used (unix time)
local function read()
  local f = io.open(M.file, "r")
  if not f then
    return {}
  end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and type(data) == "table" and data or {}
end

---@param data table<string, number>
local function write(data)
  local f = io.open(M.file, "w")
  if f then
    f:write(vim.json.encode(vim.tbl_isempty(data) and vim.empty_dict() or data))
    f:close()
  end
end

---@param path string file or directory
---@return string?
function M.root(path)
  if path == "" or path:match("^%a[%w+.-]*://") then
    return
  end
  return vim.fs.root(path, M.markers)
end

local last ---@type string?

---@param dir? string
function M.add(dir)
  if not dir then
    return
  end
  dir = vim.fs.normalize(dir)
  if dir == last or ignored(dir) then
    return
  end
  last = dir
  local data = read()
  data[dir] = os.time()
  write(data)
end

---@param dir string
function M.remove(dir)
  dir = vim.fs.normalize(dir)
  local data = read()
  data[dir] = nil
  write(data)
  if last == dir then
    last = nil
  end
end

--- Tracked projects that still exist, most recently used first
---@return string[]
function M.list()
  local data, ret = read(), {}
  for dir in pairs(data) do
    if vim.uv.fs_stat(dir) then
      ret[#ret + 1] = dir
    end
  end
  table.sort(ret, function(a, b)
    return data[a] > data[b]
  end)
  return ret
end

--- Snacks projects finder: tracked projects first, then snacks' own sources
--- (git roots of recent files and the `dev` directories).
---@type snacks.picker.finder
function M.finder(opts, ctx)
  local snacks_finder = require("snacks.picker.source.recent").projects(opts, ctx)
  local tracked = M.list()
  ---@async
  return function(cb)
    local seen = {} ---@type table<string, boolean>
    local function add(item)
      if not seen[item.file] then
        seen[item.file] = true
        cb(item)
      end
    end
    for _, dir in ipairs(tracked) do
      add({ file = dir, text = dir, dir = true })
    end
    snacks_finder(add)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("util_projects", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(ev)
      if vim.bo[ev.buf].buftype == "" then
        M.add(M.root(vim.api.nvim_buf_get_name(ev.buf)))
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = group,
    callback = function()
      M.add(M.root(assert(vim.uv.cwd())))
    end,
  })
  if vim.v.vim_did_enter == 1 then
    M.add(M.root(assert(vim.uv.cwd())))
  end

  vim.api.nvim_create_user_command("ProjectAdd", function(args)
    local dir = vim.fn.fnamemodify(args.args ~= "" and args.args or assert(vim.uv.cwd()), ":p")
    last = nil
    M.add(dir)
    vim.notify("Added project " .. vim.fs.normalize(dir))
  end, { nargs = "?", complete = "dir", desc = "Add a directory to the projects list" })
  vim.api.nvim_create_user_command("ProjectRemove", function(args)
    local dir = vim.fn.fnamemodify(args.args ~= "" and args.args or assert(vim.uv.cwd()), ":p")
    M.remove(dir)
    vim.notify("Removed project " .. vim.fs.normalize(dir))
  end, { nargs = "?", complete = "dir", desc = "Remove a directory from the projects list" })
end

return M
