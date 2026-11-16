return {
  -- Restore the last used colorscheme on startup (see lua/util/theme.lua)
  -- <leader>uC pick colorscheme (recent first, live preview, <c-x> removes from recent)
  -- <leader>uP previous colorscheme
  -- <leader>uB toggle transparency
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("util.theme").load()
      end,
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          colorschemes = require("util.theme").picker,
        },
      },
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = function()
      local transparent = vim.g.transparent_enabled ~= false
      return {
        style = "moon",
        transparent = transparent,
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = transparent and "transparent" or "dark", -- style for sidebars, see below
          floats = transparent and "transparent" or "dark", -- style for floating windows
        },
      }
    end,
  },

  -- Extra colorschemes. They're lazy-loaded the first time you select (or preview) one.
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "Mofiqul/vscode.nvim", lazy = true },
}
