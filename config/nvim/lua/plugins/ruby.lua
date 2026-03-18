local lspconfig = require("lspconfig")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          init_options = {
            addonSettings = {
              ["Ruby LSP Rails"] = {
                enablePendingMigrationsPrompt = false,
              },
              ["Ruby LSP Sorbet"] = {
                enabled = false, -- Disabled to prevent duplicate Sorbet instances
              },
            },
          },
          mason = false,
          cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },
        },
        sorbet = {
          -- Custom Sorbet setup with experimental features
          cmd = { "bundle", "exec", "srb", "tc", "--lsp", "--enable-all-experimental-lsp-features" },
          mason = false,
        },
        rubocop = {
          cmd = { "bundle", "exec", "rubocop", "--lsp" },
          root_dir = lspconfig.util.root_pattern("Gemfile", ".git", "."),
          enabled = false,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.indent) == "table" then
        -- Disable treesitter indent for ruby files
        opts.indent.disable = opts.indent.disable or {}
        table.insert(opts.indent.disable, "ruby")
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ruby = { "rubocop" },
      },
      formatters = {
        rubocop = {
          command = "bundle exec rubocop",
          args = { "-a", "--stdin", "%:p", "-f", "quiet", "--stderr" },
          stdin = true,
        },
      },
    },
  },
}
