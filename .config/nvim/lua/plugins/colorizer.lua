return {
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      buftypes = {
        "*",
        "!nofile",
        "!prompt",
        "!popup",
      },
      filetypes = {
        "*",
        "!TelescopePrompt",
        "!TelescopeResults",
        "!TelescopePreview",
        cs = { names = false },
      },
    },
  },
}
