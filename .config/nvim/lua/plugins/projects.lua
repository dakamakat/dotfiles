-- Projects picker (<leader>fp, also on the dashboard).
-- Lists, in this order:
-- * every project you've opened a file in (tracked by lua/util/projects.lua)
-- * git roots of recent files
-- * repos / solutions found in the `dev` directories below
-- In the picker: <cr> open (restores the session), <c-f> files, <c-g> grep,
-- <c-e> explorer, <c-r> recent files, <c-w> just cd, <c-x> forget project.
-- :ProjectAdd [dir] / :ProjectRemove [dir] to manage the list by hand.
return {
  {
    "folke/snacks.nvim",
    init = function()
      require("util.projects").setup()
    end,
    opts = {
      picker = {
        sources = {
          projects = {
            dev = { "~/Projects", "~/RiderProjects" },
            -- ~/Projects/Work/<client>/<repo>/.git is 4 levels deep
            max_depth = 4,
            patterns = { ".git", "*.sln", "*.slnx", "go.mod", "Cargo.toml" },
            finder = function(opts, ctx)
              return require("util.projects").finder(opts, ctx)
            end,
            actions = {
              project_forget = function(picker)
                for _, item in ipairs(picker:selected({ fallback = true })) do
                  require("util.projects").remove(item.file)
                end
                picker:find()
              end,
            },
            win = {
              input = {
                keys = {
                  ["<c-x>"] = { "project_forget", mode = { "n", "i" }, desc = "Forget project" },
                },
              },
            },
          },
        },
      },
    },
  },
}
