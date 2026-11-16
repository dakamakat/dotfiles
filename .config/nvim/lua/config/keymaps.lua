-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Colorschemes (<leader>uC picker is set up in lua/plugins/colorscheme.lua)
vim.keymap.set("n", "<leader>uP", function()
  require("util.theme").previous()
end, { desc = "Previous Colorscheme" })
Snacks.toggle({
  name = "Transparency",
  get = function()
    return vim.g.transparent_enabled == true
  end,
  set = function(state)
    require("util.theme").set_transparent(state)
  end,
}):map("<leader>uB")
