-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

---- Snacks animations
-- Set to `false` to globally disable all snacks animations
vim.g.snacks_animate = false
-- Default transparency, used until you toggle it with <leader>uB (the choice is remembered)
vim.g.transparent_enabled = true

-- Remember 1000 files instead of 100 in oldfiles (recent files / recent projects pickers)
vim.o.shada = vim.o.shada:gsub("'%d+", "'1000")
