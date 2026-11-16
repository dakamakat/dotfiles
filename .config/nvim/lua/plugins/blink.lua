-- Completion is set up by LazyVim (blink.cmp), only put overrides here.
-- Don't use `config = function()` in this spec: it replaces LazyVim's setup entirely
-- (keymaps, snippets, buffer source, cmdline completion, ...).
-- NuGet package completion in .csproj files comes from easy-dotnet's LSP, no blink source needed.
return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      -- <cr> accepts; <c-y> also accepts. Use "default" to accept with <c-y> only.
      preset = "enter",
    },
  },
}
