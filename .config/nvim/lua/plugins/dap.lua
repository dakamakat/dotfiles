-- nvim-dap, dap-ui, virtual text and the <leader>d* keymaps come from LazyVim's dap.core extra
-- (enabled in lazyvim.json). easy-dotnet registers the .NET debugger (see dotnet.lua).
-- Only the Visual Studio / Rider style keys are added here.
return {
  "mfussenegger/nvim-dap",
  -- stylua: ignore
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Start/Continue Debugging" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
    {
      "<leader>dq",
      function()
        require("dap").terminate()
        require("dap").clear_breakpoints()
      end,
      desc = "Terminate and Clear Breakpoints",
    },
  },
}
